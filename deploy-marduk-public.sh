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
  ./deploy-marduk-public.sh deploy ./marduk.env

This public script is a starter harness. It validates tools and config shape,
renders starter Terraform inputs, prints the deploy plan, and refuses to claim a
full deploy until the public operational package is implemented and clean-room
proven.
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
    cat <<'EOF'

PAUSED: public turnkey deploy is not implemented yet.

Next required engineering step:
  Add the clean-room-proven commands that drive Terraform, Talos, GitOps,
  OpenBao first install, and verification through explicit human gates.
EOF
    exit 2
    ;;

  *)
    usage >&2
    exit 2
    ;;
esac
