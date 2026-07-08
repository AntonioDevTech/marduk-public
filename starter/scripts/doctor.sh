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
need_cmd awk
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
PROXMOX_INSECURE_TLS
PROXMOX_NODE
PROXMOX_STORAGE
PROXMOX_BRIDGE
MARDUK_VLAN_ID
MARDUK_GATEWAY
MARDUK_DNS
MARDUK_CIDR_PREFIX
TALOS_IMAGE_FILE_ID
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
OPENBAO_ADDR
OPENBAO_KV_MOUNT
OPENBAO_EXTERNAL_SECRETS_NAMESPACE
OPENBAO_EXTERNAL_SECRETS_SERVICE_ACCOUNT
OPENBAO_SNAPSHOT_NAMESPACE
OPENBAO_SNAPSHOT_SERVICE_ACCOUNT
OPENBAO_ADMIN_ROLE
OPENBAO_CI_SIGNING_ROLE
OPENBAO_CI_SIGNING_SECRET_PATH
OPENBAO_RUNTIME_SECRET_PREFIXES
"

placeholder_value() {
  case "$1" in
    ""|marduk-example|replace-*|change-*|todo-*|*.example.invalid|*.example.internal|example.invalid|https://*.example.invalid*|https://*.example.internal*|git@example.invalid:*|backup.example.invalid|registry.example.invalid|192.0.2.*|198.51.100.*|203.0.113.*)
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

is_uint() {
  case "$1" in
    ""|*[!0-9]*)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

check_range() {
  name="$1"
  value="$2"
  min="$3"
  max="$4"
  if ! is_uint "$value"; then
    die "$name must be a whole number"
  fi
  if [ "$value" -lt "$min" ] || [ "$value" -gt "$max" ]; then
    die "$name must be between $min and $max"
  fi
}

check_bool() {
  name="$1"
  value="$2"
  case "$value" in
    true|false)
      ;;
    *)
      die "$name must be true or false"
      ;;
  esac
}

check_ipv4() {
  name="$1"
  value="$2"
  if ! printf '%s\n' "$value" | awk -F. '
    NF != 4 { exit 1 }
    {
      for (i = 1; i <= 4; i++) {
        if ($i !~ /^[0-9]+$/ || $i < 0 || $i > 255) exit 1
      }
    }
  '; then
    die "$name must be an IPv4 address"
  fi
}

check_name() {
  name="$1"
  value="$2"
  case "$value" in
    *[!A-Za-z0-9._-]*)
      die "$name may only contain letters, numbers, dot, underscore, or dash"
      ;;
  esac
}

check_path() {
  name="$1"
  value="$2"
  case "$value" in
    /*|*/|*//*|*[!A-Za-z0-9._/-]*)
      die "$name must be a relative OpenBao path using letters, numbers, dot, underscore, dash, or slash"
      ;;
  esac
}

case "$PROXMOX_ENDPOINT" in
  https://*)
    ;;
  *)
    die "PROXMOX_ENDPOINT must start with https://"
    ;;
esac

case "$OPENBAO_ADDR" in
  http://*|https://*)
    ;;
  *)
    die "OPENBAO_ADDR must start with http:// or https://"
    ;;
esac

check_bool PROXMOX_INSECURE_TLS "$PROXMOX_INSECURE_TLS"
check_range MARDUK_CIDR_PREFIX "$MARDUK_CIDR_PREFIX" 1 32
check_ipv4 MARDUK_GATEWAY "$MARDUK_GATEWAY"
check_ipv4 MARDUK_DNS "$MARDUK_DNS"
check_ipv4 MARDUK_NODE1_IP "$MARDUK_NODE1_IP"
check_ipv4 MARDUK_NODE2_IP "$MARDUK_NODE2_IP"
check_ipv4 MARDUK_NODE3_IP "$MARDUK_NODE3_IP"
check_ipv4 MARDUK_KUBE_VIP "$MARDUK_KUBE_VIP"
check_range MARDUK_NODE1_VMID "$MARDUK_NODE1_VMID" 1 999999999
check_range MARDUK_NODE2_VMID "$MARDUK_NODE2_VMID" 1 999999999
check_range MARDUK_NODE3_VMID "$MARDUK_NODE3_VMID" 1 999999999
check_name MARDUK_CLUSTER_NAME "$MARDUK_CLUSTER_NAME"
check_name MARDUK_NODE1_NAME "$MARDUK_NODE1_NAME"
check_name MARDUK_NODE2_NAME "$MARDUK_NODE2_NAME"
check_name MARDUK_NODE3_NAME "$MARDUK_NODE3_NAME"
check_name OPENBAO_KV_MOUNT "$OPENBAO_KV_MOUNT"
check_name OPENBAO_EXTERNAL_SECRETS_NAMESPACE "$OPENBAO_EXTERNAL_SECRETS_NAMESPACE"
check_name OPENBAO_EXTERNAL_SECRETS_SERVICE_ACCOUNT "$OPENBAO_EXTERNAL_SECRETS_SERVICE_ACCOUNT"
check_name OPENBAO_SNAPSHOT_NAMESPACE "$OPENBAO_SNAPSHOT_NAMESPACE"
check_name OPENBAO_SNAPSHOT_SERVICE_ACCOUNT "$OPENBAO_SNAPSHOT_SERVICE_ACCOUNT"
check_name OPENBAO_ADMIN_ROLE "$OPENBAO_ADMIN_ROLE"
check_name OPENBAO_CI_SIGNING_ROLE "$OPENBAO_CI_SIGNING_ROLE"
check_path OPENBAO_CI_SIGNING_SECRET_PATH "$OPENBAO_CI_SIGNING_SECRET_PATH"

for prefix in $(printf '%s' "$OPENBAO_RUNTIME_SECRET_PREFIXES" | tr ',' ' '); do
  check_name OPENBAO_RUNTIME_SECRET_PREFIX "$prefix"
done

case "$MARDUK_VLAN_ID" in
  none)
    ;;
  *)
    check_range MARDUK_VLAN_ID "$MARDUK_VLAN_ID" 1 4094
    ;;
esac

if [ "$ALLOW_PLACEHOLDERS" -eq 1 ]; then
  echo "starter config shape: OK with placeholders allowed"
else
  echo "starter config shape: OK"
fi
