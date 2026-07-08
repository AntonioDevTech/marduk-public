#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT"

CONFIG="${1:-starter/config/marduk.env}"
OUTPUT="${2:--}"

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: config not found: $CONFIG" >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$CONFIG"

hcl_string() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

if [ "$MARDUK_VLAN_ID" = "none" ]; then
  vlan_hcl="null"
else
  vlan_hcl="$MARDUK_VLAN_ID"
fi

render() {
  cat <<EOF
# Generated from $CONFIG by starter/scripts/render-terraform-tfvars.sh.
# Do not commit real private topology values to a public repo.

proxmox_endpoint     = "$(hcl_string "$PROXMOX_ENDPOINT")"
proxmox_insecure_tls = $PROXMOX_INSECURE_TLS
node_name            = "$(hcl_string "$PROXMOX_NODE")"
talos_image_file_id  = "$(hcl_string "$TALOS_IMAGE_FILE_ID")"
disk_datastore       = "$(hcl_string "$PROXMOX_STORAGE")"
bridge               = "$(hcl_string "$PROXMOX_BRIDGE")"
vlan_id              = $vlan_hcl
gateway              = "$(hcl_string "$MARDUK_GATEWAY")"
dns_server           = "$(hcl_string "$MARDUK_DNS")"

nodes = {
  "$(hcl_string "$MARDUK_NODE1_NAME")" = { vm_id = $MARDUK_NODE1_VMID, address = "$(hcl_string "$MARDUK_NODE1_IP")/$MARDUK_CIDR_PREFIX" }
  "$(hcl_string "$MARDUK_NODE2_NAME")" = { vm_id = $MARDUK_NODE2_VMID, address = "$(hcl_string "$MARDUK_NODE2_IP")/$MARDUK_CIDR_PREFIX" }
  "$(hcl_string "$MARDUK_NODE3_NAME")" = { vm_id = $MARDUK_NODE3_VMID, address = "$(hcl_string "$MARDUK_NODE3_IP")/$MARDUK_CIDR_PREFIX" }
}
EOF
}

if [ "$OUTPUT" = "-" ]; then
  render
else
  render > "$OUTPUT"
  echo "wrote $OUTPUT"
fi
