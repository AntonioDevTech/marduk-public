#!/usr/bin/env sh
set -eu

usage() {
  cat <<'EOF'
Usage:
  starter/scripts/doctor.sh [config-path] [--allow-placeholders]

Checks public-starter tooling and validates the sourceable marduk.env config
shape. Real deploy configs should not contain placeholder values.
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

warn() {
  echo "WARN: $*" >&2
}

CONFIG="${1:-starter/config/marduk.env}"
ALLOW_PLACEHOLDERS=0

if [ "${2:-}" = "--allow-placeholders" ]; then
  ALLOW_PLACEHOLDERS=1
elif [ "${1:-}" = "--help" ]; then
  usage
  exit 0
elif [ "$#" -gt 1 ]; then
  usage >&2
  exit 2
fi

if [ ! -f "$CONFIG" ]; then
  die "config not found: $CONFIG; copy starter/config/marduk.env.example to your private marduk.env"
fi

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    die "missing required command: $1"
  fi
}

optional_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "$1: OK"
  else
    warn "optional command missing: $1"
  fi
}

need_cmd sh
need_cmd grep
need_cmd sed
optional_cmd terraform
optional_cmd talosctl
optional_cmd kubectl
optional_cmd helm
optional_cmd docker
optional_cmd go

# shellcheck disable=SC1090
. "$CONFIG"

required_vars="
MARDUK_CLUSTER_NAME
PROXMOX_ENDPOINT
PROXMOX_NODE
PROXMOX_STORAGE
PROXMOX_BRIDGE
MARDUK_VLAN_ID
MARDUK_GATEWAY
MARDUK_DNS
MARDUK_NODE1_NAME
MARDUK_NODE1_IP
MARDUK_NODE1_VMID
MARDUK_NODE2_NAME
MARDUK_NODE2_IP
MARDUK_NODE2_VMID
MARDUK_NODE3_NAME
MARDUK_NODE3_IP
MARDUK_NODE3_VMID
MARDUK_KUBE_VIP
GITOPS_REPO_URL
REGISTRY_HOSTNAME
PUBLIC_DOMAIN
BACKUP_TARGET_HOST
OBSERVABILITY_ENDPOINT
"

placeholder_value() {
  case "$1" in
    ""|replace-*|change-*|todo-*|*.example.invalid|example.invalid|https://*.example.invalid*|git@example.invalid:*|backup.example.invalid|registry.example.invalid)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

for var in $required_vars; do
  eval "value=\${$var:-}"
  if [ -z "$value" ]; then
    die "$var is empty"
  fi
  if placeholder_value "$value" && [ "$ALLOW_PLACEHOLDERS" -ne 1 ]; then
    die "$var still looks like a placeholder: $value"
  fi
done

if [ "$ALLOW_PLACEHOLDERS" -eq 1 ]; then
  echo "starter config shape: OK with placeholders allowed"
else
  echo "starter config shape: OK"
fi
