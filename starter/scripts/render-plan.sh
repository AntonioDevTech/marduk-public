#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT"

CONFIG="${1:-starter/config/marduk.env.example}"

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: config not found: $CONFIG" >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$CONFIG"

if [ "$MARDUK_VLAN_ID" = "none" ]; then
  vlan_text="untagged"
else
  vlan_text="VLAN $MARDUK_VLAN_ID"
fi

cat <<EOF
MARDUK public deploy plan

Config file:
  $CONFIG

Concrete topology from config:
  Cluster: $MARDUK_CLUSTER_NAME
  Proxmox: $PROXMOX_ENDPOINT on node $PROXMOX_NODE
  Storage/bridge: $PROXMOX_STORAGE / $PROXMOX_BRIDGE ($vlan_text)
  Network: gateway $MARDUK_GATEWAY, DNS $MARDUK_DNS, prefix /$MARDUK_CIDR_PREFIX
  Kubernetes VIP: $MARDUK_KUBE_VIP
  GitOps repo: $GITOPS_REPO_URL
  Registry: $REGISTRY_HOSTNAME
  Public domain: $PUBLIC_DOMAIN
  Backup target: $BACKUP_TARGET_HOST
  Observability endpoint: $OBSERVABILITY_ENDPOINT

Talos VM substrate:
  $MARDUK_NODE1_NAME vmid=$MARDUK_NODE1_VMID ip=$MARDUK_NODE1_IP/$MARDUK_CIDR_PREFIX
  $MARDUK_NODE2_NAME vmid=$MARDUK_NODE2_VMID ip=$MARDUK_NODE2_IP/$MARDUK_CIDR_PREFIX
  $MARDUK_NODE3_NAME vmid=$MARDUK_NODE3_VMID ip=$MARDUK_NODE3_IP/$MARDUK_CIDR_PREFIX

Generated local artifacts:
  starter/scripts/render-terraform-tfvars.sh "$CONFIG" starter/terraform/proxmox/terraform.tfvars
  starter/scripts/render-openbao-bootstrap.sh "$CONFIG" starter/security/openbao-bootstrap
  starter/scripts/openbao-first-install.sh dry-run "$CONFIG"

Expected private deploy order:
  1. Validate local tools and this config.
  2. Render starter/terraform/proxmox/terraform.tfvars from this config.
  3. Render starter/security/openbao-bootstrap from this config.
  4. Run terraform init/plan/apply for the Proxmox Talos VM substrate.
  5. Generate fresh Talos secrets in private custody and bootstrap Kubernetes.
  6. Seed Cilium and Argo CD.
  7. Dry-run the OpenBao first-install ceremony and review every human gate.
  8. Perform the live OpenBao first-install ceremony and save custody shares offline.
  9. Apply the generated OpenBao bootstrap bundle.
  10. Create and privately save AppRole credential files.
  11. Configure Kubernetes auth with private cluster trust material.
  12. Seed runtime secrets through OpenBao and External Secrets, then revoke root.
  13. Verify post-root admin access with the saved admin AppRole file.
  14. Prove firewall, DNS, public route, observability, backup, admission, failover, and DR gates.

Manual gates that stay human-owned:
  - OpenBao custody shares and any root-of-trust ceremony.
  - Signing-key custody.
  - Firewall and DNS ownership.
  - External account tokens.
  - Backup target trust.

Honest state:
  This public repo now validates config, renders starter Terraform inputs, and
  proves OpenBao helper mechanics, AppRole credential file creation, Kubernetes
  auth config submission, real Kubernetes ServiceAccount login, policy scoping,
  External Secrets sync, and post-root access against disposable OpenBao/kind
  resources.
  It is still not a full turnkey deployer until a clean-room Proxmox install is
  implemented and proven from user-supplied private inputs.
EOF
