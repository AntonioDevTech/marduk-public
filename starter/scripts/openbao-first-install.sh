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
  starter/scripts/openbao-first-install.sh apply-bootstrap [marduk.env] [bundle-dir]
  starter/scripts/openbao-first-install.sh revoke-root [marduk.env]
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

root_token() {
  if [ ! -f "$INIT_JSON" ]; then
    die "init JSON not found: $INIT_JSON"
  fi
  mode=$(stat -c '%a' "$INIT_JSON" 2>/dev/null || echo unknown)
  if [ "$mode" != "600" ]; then
    die "init JSON must have mode 600, got: $mode"
  fi
  python3 - "$INIT_JSON" <<'PY'
import json
import sys

d = json.load(open(sys.argv[1]))
token = d.get("root_token")
if not token:
    raise SystemExit("missing root_token in init JSON")
print(token)
PY
}

bao_curl() {
  method="$1"
  token="$2"
  path="$3"
  data_file="${4:-}"
  url="$OPENBAO_ADDR/v1/$path"
  if [ -n "$data_file" ]; then
    curl -fsS -X "$method" -H "X-Vault-Token: $token" --data @"$data_file" "$url"
  else
    curl -fsS -X "$method" -H "X-Vault-Token: $token" "$url"
  fi
}

bao_http_code() {
  method="$1"
  token="$2"
  path="$3"
  data_file="${4:-}"
  url="$OPENBAO_ADDR/v1/$path"
  if [ -n "$data_file" ]; then
    curl -sS -o /tmp/marduk-openbao-http.out -w '%{http_code}' \
      -X "$method" -H "X-Vault-Token: $token" --data @"$data_file" "$url"
  else
    curl -sS -o /tmp/marduk-openbao-http.out -w '%{http_code}' \
      -X "$method" -H "X-Vault-Token: $token" "$url"
  fi
}

json_policy_payload() {
  python3 - "$1" <<'PY'
import json
import sys

print(json.dumps({"policy": open(sys.argv[1]).read()}))
PY
}

json_kv_payload() {
  python3 - <<'PY'
import json

print(json.dumps({"type": "kv", "options": {"version": "2"}}))
PY
}

json_auth_payload() {
  python3 - "$1" <<'PY'
import json
import sys

print(json.dumps({"type": sys.argv[1]}))
PY
}

ensure_mount() {
  token="$1"
  mount="$2"
  if bao_curl GET "$token" "sys/mounts" | python3 -c '
import json
import sys

d = json.load(sys.stdin)
mount = sys.argv[1].rstrip("/") + "/"
raise SystemExit(0 if mount in d else 1)
' "$mount"
  then
    return 0
  fi
  payload=$(mktemp)
  json_kv_payload > "$payload"
  bao_curl POST "$token" "sys/mounts/$mount" "$payload" >/dev/null
  rm -f "$payload"
}

ensure_auth() {
  token="$1"
  auth="$2"
  if bao_curl GET "$token" "sys/auth" | python3 -c '
import json
import sys

d = json.load(sys.stdin)
auth = sys.argv[1].rstrip("/") + "/"
raise SystemExit(0 if auth in d else 1)
' "$auth"
  then
    return 0
  fi
  payload=$(mktemp)
  json_auth_payload "$auth" > "$payload"
  bao_curl POST "$token" "sys/auth/$auth" "$payload" >/dev/null
  rm -f "$payload"
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
  5. Run apply-bootstrap to apply the generated non-secret mount, auth, policy,
     and role shape.
  6. Configure private Kubernetes auth, create AppRole secret IDs, and seed real
     secrets through private files or stdin.
  7. Run revoke-root after first backup and verification.

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

  apply-bootstrap)
    preflight
    bundle="${3:-starter/security/openbao-bootstrap}"
    for file in \
      "$bundle/policies/eso-ro.hcl" \
      "$bundle/policies/raft-snapshot-ro.hcl" \
      "$bundle/policies/ci-cosign-ro.hcl" \
      "$bundle/policies/admin.hcl" \
      "$bundle/payloads/kubernetes-role-eso.json" \
      "$bundle/payloads/kubernetes-role-raft-snapshot.json" \
      "$bundle/payloads/approle-admin.json" \
      "$bundle/payloads/approle-ci-signing.json"
    do
      [ -f "$file" ] || die "bundle file missing: $file"
    done

    token=$(root_token)
    seal_status | python3 -c 'import json,sys; d=json.load(sys.stdin); raise SystemExit(0 if d.get("initialized") and not d.get("sealed") else 1)' \
      || die "OpenBao must be initialized and unsealed before apply-bootstrap"

    ensure_mount "$token" "$OPENBAO_KV_MOUNT"
    ensure_auth "$token" kubernetes
    ensure_auth "$token" approle

    tmp_payload=$(mktemp)
    for name in eso-ro raft-snapshot-ro ci-cosign-ro admin; do
      json_policy_payload "$bundle/policies/$name.hcl" > "$tmp_payload"
      bao_curl PUT "$token" "sys/policies/acl/$name" "$tmp_payload" >/dev/null
    done
    rm -f "$tmp_payload"

    bao_curl POST "$token" "auth/kubernetes/role/eso" "$bundle/payloads/kubernetes-role-eso.json" >/dev/null
    bao_curl POST "$token" "auth/kubernetes/role/raft-snapshot" "$bundle/payloads/kubernetes-role-raft-snapshot.json" >/dev/null
    bao_curl POST "$token" "auth/approle/role/$OPENBAO_ADMIN_ROLE" "$bundle/payloads/approle-admin.json" >/dev/null
    bao_curl POST "$token" "auth/approle/role/$OPENBAO_CI_SIGNING_ROLE" "$bundle/payloads/approle-ci-signing.json" >/dev/null
    unset token

    cat <<EOF
OpenBao bootstrap apply: PASS
kv_mount=$OPENBAO_KV_MOUNT policies=4 auth_methods=kubernetes,approle roles=4
secret_ids_created=false
kubernetes_auth_configured=false
EOF
    ;;

  revoke-root)
    preflight
    token=$(root_token)
    bao_curl GET "$token" "auth/token/lookup-self" >/dev/null
    code=$(bao_http_code POST "$token" "auth/token/revoke-self")
    after=$(bao_http_code GET "$token" "auth/token/lookup-self" || true)
    unset token
    if [ "$code" != "204" ] || [ "$after" != "403" ]; then
      die "root revoke proof failed: revoke_http=$code lookup_after=$after"
    fi
    if [ -f "$INIT_JSON" ]; then
      if command -v shred >/dev/null 2>&1; then
        shred -u "$INIT_JSON"
      else
        rm -f "$INIT_JSON"
      fi
    fi
    rm -f /tmp/marduk-openbao-http.out
    echo "OpenBao root revoke: PASS revoke_http=$code lookup_after=$after init_json_removed=true"
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
