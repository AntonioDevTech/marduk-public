#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")" && pwd)
cd "$ROOT"

usage() {
  cat <<'EOF'
Usage:
  ./deploy-marduk-public.sh doctor
  ./deploy-marduk-public.sh verify-config ./marduk.env
  ./deploy-marduk-public.sh plan [./marduk.env]
  ./deploy-marduk-public.sh render-terraform [./marduk.env] [output.tfvars]
  ./deploy-marduk-public.sh openbao-plan [./marduk.env]
  ./deploy-marduk-public.sh render-openbao [./marduk.env] [output-dir]
  ./deploy-marduk-public.sh openbao-first-install-dry-run [./marduk.env]
  ./deploy-marduk-public.sh openbao-kubernetes-login-proof
  ./deploy-marduk-public.sh openbao-eso-sync-proof
  ./deploy-marduk-public.sh openbao-secret-seeding-proof
  ./deploy-marduk-public.sh openbao-backup-proof
  ./deploy-marduk-public.sh public-edge-proof
  ./deploy-marduk-public.sh public-proof [./marduk.env]
  ./deploy-marduk-public.sh deploy ./marduk.env

This public script is a starter harness. It validates tools and config shape,
renders starter Terraform and OpenBao inputs, prints the deploy plan, and
refuses to claim a full deploy until the public operational package is
implemented and clean-room proven.
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
    config="${2:-starter/config/marduk.env.example}"
    if [ "$config" = "starter/config/marduk.env.example" ]; then
      starter/scripts/doctor.sh "$config" --allow-placeholders
    else
      starter/scripts/doctor.sh "$config"
    fi
    starter/scripts/render-plan.sh "$config"
    ;;

  render-terraform)
    config="${2:-starter/config/marduk.env.example}"
    output="${3:--}"
    if [ "$config" = "starter/config/marduk.env.example" ]; then
      starter/scripts/doctor.sh "$config" --allow-placeholders
    else
      starter/scripts/doctor.sh "$config"
    fi
    starter/scripts/render-terraform-tfvars.sh "$config" "$output"
    ;;

  openbao-plan)
    config="${2:-starter/config/marduk.env.example}"
    if [ "$config" = "starter/config/marduk.env.example" ]; then
      starter/scripts/doctor.sh "$config" --allow-placeholders
    else
      starter/scripts/doctor.sh "$config"
    fi
    starter/scripts/render-openbao-plan.sh "$config"
    ;;

  render-openbao)
    config="${2:-starter/config/marduk.env.example}"
    output="${3:-starter/security/openbao-bootstrap}"
    if [ "$config" = "starter/config/marduk.env.example" ]; then
      starter/scripts/doctor.sh "$config" --allow-placeholders
    else
      starter/scripts/doctor.sh "$config"
    fi
    starter/scripts/render-openbao-bootstrap.sh "$config" "$output"
    ;;

  openbao-first-install-dry-run)
    config="${2:-starter/config/marduk.env.example}"
    if [ "$config" = "starter/config/marduk.env.example" ]; then
      starter/scripts/doctor.sh "$config" --allow-placeholders
    else
      starter/scripts/doctor.sh "$config"
    fi
    starter/scripts/openbao-first-install.sh dry-run "$config"
    ;;

  openbao-kubernetes-login-proof)
    starter/scripts/openbao-kubernetes-login-proof.sh
    ;;

  openbao-eso-sync-proof)
    starter/scripts/openbao-eso-sync-proof.sh
    ;;

  openbao-secret-seeding-proof)
    starter/scripts/openbao-secret-seeding-proof.sh
    ;;

  openbao-backup-proof)
    starter/scripts/openbao-backup-proof.sh
    ;;

  public-edge-proof)
    starter/scripts/public-edge-proof.sh
    ;;

  public-proof)
    config="${2:-starter/config/marduk.env.example}"
    tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/marduk-public-proof.XXXXXX")
    cleanup_public_proof() {
      rm -rf "$tmpdir"
    }
    trap cleanup_public_proof EXIT INT TERM
    if [ "$config" = "starter/config/marduk.env.example" ]; then
      starter/scripts/doctor.sh "$config" --allow-placeholders
    else
      starter/scripts/doctor.sh "$config"
    fi
    "$0" doctor
    "$0" plan "$config"
    "$0" render-terraform "$config" "$tmpdir/terraform.tfvars"
    "$0" openbao-plan "$config"
    "$0" render-openbao "$config" "$tmpdir/openbao-bootstrap"
    "$0" openbao-first-install-dry-run "$config"
    make docker-build
    "$0" openbao-kubernetes-login-proof
    "$0" openbao-eso-sync-proof
    "$0" openbao-secret-seeding-proof
    "$0" openbao-backup-proof
    "$0" public-edge-proof
    cat <<'EOF'

MARDUK public proof: PASS

Honest boundary:
  The public starter, config rendering, OpenBao helper mechanics, ESO sync,
  runtime seeding, backup shipping, and local edge route proof all passed.
  This is still not a real Proxmox/Talos/GitOps deployment until a user supplies
  private infrastructure inputs and runs the real infrastructure stages.
EOF
    ;;

  deploy)
    config="${2:-}"
    if [ -z "$config" ]; then
      echo "ERROR: deploy requires a real private marduk.env path" >&2
      exit 2
    fi
    "$0" doctor
    "$0" verify-config "$config"
    "$0" plan "$config"
    "$0" render-terraform "$config" starter/terraform/proxmox/terraform.tfvars
    "$0" openbao-plan "$config"
    "$0" render-openbao "$config" starter/security/openbao-bootstrap
    "$0" openbao-first-install-dry-run "$config"
    cat <<'EOF'

PAUSED: public turnkey deploy is not implemented yet.

Next required engineering step:
  Add the clean-room-proven commands that drive Terraform, Talos, GitOps,
  OpenBao first install, and verification through explicit human gates.

Public-safe proof command available now:
  ./deploy-marduk-public.sh public-proof
EOF
    exit 2
    ;;

  *)
    usage >&2
    exit 2
    ;;
esac
