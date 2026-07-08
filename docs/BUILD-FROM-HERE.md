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
make docker-build
make run-docker
```

`make test` uses local Go when available and falls back to Docker when Go is not
installed.

## Platform Build Path

The platform path is intentionally a starter today, because real infrastructure
values must be private and the sanitized public deploy wrapper has not been
published yet.

Recommended order:

1. Prepare a private operational repo from `starter/`.
2. Copy `starter/config/marduk.env.example` to `marduk.env`.
3. Fill in Terraform variables for your Proxmox endpoint, storage, bridge, and
   node IP plan.
4. Run `starter/scripts/doctor.sh ./marduk.env`.
5. Run Terraform to create the VMs.
6. Generate Talos machine configs from your own secrets.
7. Bootstrap Kubernetes.
8. Install Cilium and Argo CD.
9. Point Argo CD at your private operational repo.
10. Add registry, signing, vault, admission policy, observability, and backups.
11. Use `docs/EXTERNAL-GATES.md` to prove human-owned trust gates.
12. Use `docs/FAILOVER-DR-MATRIX.md` to prove recovery claims.
13. Write evidence for each claim before you make it publicly.

## What Is Still Missing For Turnkey Public Deploy

The private MARDUK estate has a one-command wrapper that orchestrates Terraform,
Talos, GitOps, OpenBao restore, external gate checks, and final verification.
This public repo does not yet include a sanitized equivalent.

Before this repo can honestly say "clone and deploy," it needs:

1. A sanitized deploy wrapper with all estate-specific values moved into example
   config files. The public starter harness now exposes `doctor`,
   `verify-config`, and `plan`; full deploy orchestration is still pending.
2. A first-install OpenBao path for users with no existing snapshot or custody.
3. A documented external-gate matrix for firewall, DNS, public edge, backups, and
   observability.
4. A clean-room proof from an anonymous clone and documented inputs.

## Why The Public Repo Is Not The Operational Repo

The operational repo for a real platform contains sensitive topology and recovery
details. Publishing that directly would expose too much. This repo keeps the
architecture and starter code while removing the private values.
