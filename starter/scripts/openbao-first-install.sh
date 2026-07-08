#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT"

usage() {
  cat <<'EOF'
Usage:
  starter/scripts/openbao-first-install.sh dry-run [marduk.env]
  starter/scripts/openbao-first-install.sh preflight [marduk.env]
  starter/scripts/openbao-first-install.sh status [marduk.env]
  starter/scripts/openbao-first-install.sh init [marduk.env] --i-understand-this-prints-tier0-shares
  starter/scripts/openbao-first-install.sh unseal [marduk.env]
  starter/scripts/openbao-first-install.sh shred-init [marduk.env]

This helper is for a brand-new OpenBao with no existing snapshot. It never
belongs in public CI except dry-run/preflight. The init command prints unseal
shares exactly because a human must save them to private custody.
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

read_secret() {
  prompt="$1"
  var_name="$2"
  printf '%s' "$prompt" >&2
  old_stty=""
  if command -v stty >/dev/null 2>&1 && [ -t 0 ]; then
    old_stty=$(stty -g 2>/dev/null || true)
    stty -echo 2>/dev/null || true
  fi
  IFS= read -r secret_value
  if [ -n "$old_stty" ]; then
    stty "$old_stty" 2>/dev/null || true
  fi
  printf '\n' >&2
  eval "$var_name=\$secret_value"
}

json_summary() {
  python3 -c 'import json,sys; d=json.load(sys.stdin); print("initialized=%s sealed=%s threshold=%s shares=%s progress=%s version=%s" % (d.get("initialized"), d.get("sealed"), d.get("t"), d.get("n"), d.get("progress"), d.get("version")))'
}

cmd="${1:-help}"
config="${2:-starter/config/marduk.env.example}"
confirm="${3:-}"

case "$cmd" in
  help|--help|-h)
    usage
    exit 0
    ;;
esac

if [ ! -f "$config" ]; then
  die "config not found: $config"
fi

# shellcheck disable=SC1090
. "$config"

INIT_JSON="${OPENBAO_INIT_JSON:-$HOME/.openbao/marduk-first-init.json}"

preflight() {
  need_cmd curl
    need_cmd python3
    need_cmd chmod
    need_cmd mkdir
    need_cmd stty
  case "$OPENBAO_ADDR" in
    http://*|https://*)
      ;;
    *)
      die "OPENBAO_ADDR must start with http:// or https://"
      ;;
  esac
}

seal_status() {
  curl -fsS "$OPENBAO_ADDR/v1/sys/seal-status"
}

case "$cmd" in
  dry-run)
    preflight
    cat <<EOF
OpenBao first-install dry run

Config: $config
OpenBao address: $OPENBAO_ADDR
Init JSON path: $INIT_JSON
KV mount to enable after init: $OPENBAO_KV_MOUNT/
Bootstrap bundle command:
  starter/scripts/render-openbao-bootstrap.sh "$config" starter/security/openbao-bootstrap

Live order:
  1. Verify OpenBao is reachable and initialized=false sealed=true.
  2. Run init with the explicit confirmation flag.
  3. Save all printed unseal shares to password manager plus paper/offline custody.
  4. Run unseal and enter any 2 saved shares.
  5. Use the root token from the mode-600 init JSON only long enough to apply
     mounts, auth methods, policies, roles, and seed initial secrets.
  6. Revoke root and run shred-init.

This dry run does not contact OpenBao and prints no secret values.
EOF
    ;;

  preflight)
    preflight
    echo "OpenBao first-install preflight: PASS"
    ;;

  status)
    preflight
    seal_status | json_summary
    ;;

  init)
    preflight
    if [ "$confirm" != "--i-understand-this-prints-tier0-shares" ]; then
      die "init requires --i-understand-this-prints-tier0-shares"
    fi
    mkdir -p "$(dirname "$INIT_JSON")"
    umask 077
    if seal_status | python3 -c 'import json,sys; raise SystemExit(0 if not json.load(sys.stdin).get("initialized") else 1)'; then
      :
    else
      die "OpenBao is already initialized or seal-status was not fresh/uninitialized"
    fi
    curl -fsS -X POST "$OPENBAO_ADDR/v1/sys/init" \
      --data '{"secret_shares":3,"secret_threshold":2}' > "$INIT_JSON"
    chmod 600 "$INIT_JSON"
    python3 - "$INIT_JSON" <<'PY'
import json
import sys

d = json.load(open(sys.argv[1]))
print("SAVE THESE THREE UNSEAL SHARES NOW.")
print("Do not paste them into chat, Git, tickets, public docs, or shared logs.")
for i, share in enumerate(d["keys_base64"], 1):
    print(f"share_{i}={share}")
print()
print("Root token was written to the mode-600 init JSON file.")
print("Use it only long enough to finish bootstrap, then revoke it and shred the file.")
PY
    ;;

  unseal)
    preflight
    read_secret "OpenBao share 1: " S1
    printf '%s' "$S1" \
      | python3 -c 'import json,sys; print(json.dumps({"key": sys.stdin.read().strip()}))' \
      | curl -fsS -X PUT "$OPENBAO_ADDR/v1/sys/unseal" --data @- \
      | json_summary
    unset S1

    read_secret "OpenBao share 2: " S2
    printf '%s' "$S2" \
      | python3 -c 'import json,sys; print(json.dumps({"key": sys.stdin.read().strip()}))' \
      | curl -fsS -X PUT "$OPENBAO_ADDR/v1/sys/unseal" --data @- \
      | json_summary
    unset S2
    ;;

  shred-init)
    preflight
    if [ -f "$INIT_JSON" ]; then
      if command -v shred >/dev/null 2>&1; then
        shred -u "$INIT_JSON"
      else
        rm -f "$INIT_JSON"
      fi
      echo "removed $INIT_JSON"
    else
      echo "init JSON not found: $INIT_JSON"
    fi
    ;;

  *)
    usage >&2
    exit 2
    ;;
esac
