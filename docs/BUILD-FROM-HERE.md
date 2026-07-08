# Build From Here

This public repo is designed to be useful in two ways:

1. Run and inspect the demo app locally.
2. Use `starter/` as a sanitized platform blueprint for your own environment.

## Local App Build

```bash
make doctor
make test
make starter-doctor
./deploy-marduk-public.sh plan
./deploy-marduk-public.sh render-terraform starter/config/marduk.env.example -
./deploy-marduk-public.sh openbao-plan
./deploy-marduk-public.sh render-openbao starter/config/marduk.env.example /tmp/marduk-openbao-bootstrap
./deploy-marduk-public.sh openbao-first-install-dry-run
make openbao-backup-proof
make public-edge-proof
./deploy-marduk-public.sh public-proof
make docker-build
make run-docker
```

`make test` uses local Go when available and falls back to Docker when Go is not
installed.

## Platform Build Path

The platform path is intentionally a starter today, because real infrastructure
values must be private. The public-safe wrapper exists for local proof, but it
does not yet orchestrate a real Proxmox/Talos/GitOps install.

Recommended order:

1. Prepare a private operational repo from `starter/`.
2. Copy `starter/config/marduk.env.example` to `marduk.env`.
3. Fill in Terraform variables for your Proxmox endpoint, storage, bridge, and
   node IP plan.
4. Run `starter/scripts/doctor.sh ./marduk.env`.
5. Run `./deploy-marduk-public.sh plan ./marduk.env`.
6. Render `starter/terraform/proxmox/terraform.tfvars` from `marduk.env`.
7. Render `starter/security/openbao-bootstrap` from `marduk.env`.
8. Dry-run the OpenBao first-install ceremony and review every human gate.
9. Run Terraform to create the VMs.
10. Generate Talos machine configs from your own secrets.
11. Bootstrap Kubernetes.
12. Install Cilium and Argo CD.
13. Point Argo CD at your private operational repo.
14. Add registry, signing, vault, admission policy, observability, and backups.
15. Use `docs/EXTERNAL-GATES.md` to prove human-owned trust gates.
16. Use `docs/FAILOVER-DR-MATRIX.md` to prove recovery claims.
17. Write evidence for each claim before you make it publicly.

## What Is Still Missing For A Full Public Proxmox Install

The private MARDUK estate has a one-command wrapper that orchestrates Terraform,
Talos, GitOps, OpenBao restore, external gate checks, and final verification.
This public repo has a public-safe wrapper for disposable proofs, not the full
sanitized infrastructure deploy wrapper.

Before this repo can honestly say "clone and fully install on Proxmox," it
needs:

1. Real infrastructure orchestration with all estate-specific values moved into
   documented config files. The public harness exposes `doctor`,
   `verify-config`, `plan`, `render-terraform`, `openbao-plan`,
   `render-openbao`, and `public-proof`; actual Proxmox/Talos apply logic is
   still pending.
2. A live-tested first-install OpenBao path for users with no existing snapshot
   or custody. The public starter can render the non-secret policy and role
   bundle, dry-run the ceremony, create AppRole credential files, submit
   Kubernetes auth config from a private file, prove a real ServiceAccount login
   through disposable kind/OpenBao resources, prove External Secrets can sync
   OpenBao values into Kubernetes Secrets, seed public-safe registry and backup
   values through a mode-600 file, revoke root, and prove post-root helper
   mechanics now. It can also create a real disposable raft snapshot and ship it
   to a disposable forced-command SSH receiver. Real operator-owned secret
   values, real DNS or Cloudflare ownership, real infrastructure orchestration,
   and clean public Proxmox proof are still pending.
3. A second-hypervisor proof from an anonymous clone and documented inputs.

## Why The Public Repo Is Not The Operational Repo

The operational repo for a real platform contains sensitive topology and recovery
details. Publishing that directly would expose too much. This repo keeps the
architecture and starter code while removing the private values.
