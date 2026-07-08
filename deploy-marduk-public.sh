#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")" && pwd)
cd "$ROOT"

usage() {
  cat <<'EOF'
Usage:
  ./deploy-marduk-public.sh doctor
  ./deploy-marduk-public.sh verify-config ./marduk.env
  ./deploy-marduk-public.sh plan
  ./deploy-marduk-public.sh deploy

This public script is a starter harness. It validates tools and config shape,
prints the deploy plan, and refuses to claim a full deploy until the public
operational package is implemented and clean-room proven.
EOF
}

cmd="${1:-help}"

case "$cmd" in
  help|--help|-h)
    usage
    ;;

  doctor)
    make doctor
    make test
    make starter-doctor
    ;;

  verify-config)
    config="${2:-marduk.env}"
    starter/scripts/doctor.sh "$config"
    ;;

  plan)
    cat <<'EOF'
MARDUK public deploy plan

Automated in this public starter today:
  1. Check local app tooling.
  2. Test the demo app with local Go or Docker fallback.
  3. Validate the public starter config shape.
  4. Build the demo app container.

Still manual or future-package work:
  1. Copy starter/ into a private operational repo.
  2. Fill marduk.env with private topology values.
  3. Run Terraform for your Proxmox substrate.
  4. Generate fresh Talos secrets and bootstrap Kubernetes.
  5. Seed Cilium and Argo CD.
  6. Perform the OpenBao first-install ceremony.
  7. Seed real runtime secrets through your vault.
  8. Prove external gates, observability, backups, admission, and recovery.

Manual gates that must remain human-owned:
  - OpenBao custody shares.
  - Signing key custody.
  - Firewall and DNS ownership.
  - External account tokens.
  - Backup target trust.

Honest state:
  This public repo is a starter harness, not a full turnkey deployer yet.
EOF
    ;;

  deploy)
    "$0" doctor
    "$0" plan
    cat <<'EOF'

PAUSED: public turnkey deploy is not implemented yet.

Next required engineering step:
  Add a sanitized operational deploy wrapper that consumes marduk.env and drives
  Terraform, Talos, GitOps, OpenBao first install, and verification through
  explicit human gates.
EOF
    exit 2
    ;;

  *)
    usage >&2
    exit 2
    ;;
esac
