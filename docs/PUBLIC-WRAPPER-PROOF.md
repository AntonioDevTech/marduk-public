# Public Wrapper Proof

Date: 2026-07-08

## Purpose

This proof checks the sanitized public wrapper parity now available in this repo.
It does not claim to deploy a real Proxmox/Talos/GitOps estate. It proves the
public-safe wrapper can run the full local proof ladder as one command and stop
with an honest real-infrastructure boundary.

## Public Helper Commit

```text
commit: 70d15e65550d1c06138a45e1705f530c41e11351
workflow: ci
run: https://github.com/AntonioDevTech/marduk-public/actions/runs/28969268556
status: Success
```

## Command

```bash
./deploy-marduk-public.sh public-proof
```

The command requires Docker, kind, kubectl, Helm, curl, python3, ssh,
ssh-keygen, ssh-keyscan, sha256sum, terraform, and talosctl. It creates only
disposable local resources and removes them before exit.

## Safe Output Shape

```text
MARDUK public proof: PASS

Honest boundary:
  The public starter, config rendering, OpenBao helper mechanics, ESO sync,
  runtime seeding, backup shipping, and local edge route proof all passed.
  This is still not a real Proxmox/Talos/GitOps deployment until a user supplies
  private infrastructure inputs and runs the real infrastructure stages.
```

## What Was Proven

The wrapper runs, in order:

- starter config validation
- demo app tests through the Docker-backed Go path when local Go is absent
- generated deploy plan
- generated Terraform starter variables
- generated OpenBao first-install plan
- generated OpenBao bootstrap bundle
- OpenBao first-install dry run
- demo app container build
- disposable OpenBao Kubernetes-login proof
- disposable OpenBao External Secrets sync proof
- disposable OpenBao runtime secret seeding proof
- disposable OpenBao backup shipping proof
- disposable public-edge route proof

## Clean Clone Proof

A fresh anonymous GitHub clone at commit
`70d15e65550d1c06138a45e1705f530c41e11351` passed:

- shell syntax for `deploy-marduk-public.sh` and all starter scripts
- `./deploy-marduk-public.sh public-proof`
- `git diff --check`
- gitleaks 8.28.0 with no leaks
- private-value denylist scan with no hits
- cleanup checks showing no leftover disposable kind cluster, OpenBao container,
  backup receiver container, edge proxy container, Docker network, or proof temp
  directory

## Still Not Proven

This does not yet prove:

- a real public Proxmox/Talos/Kubernetes/GitOps install
- a user-owned real DNS zone, Cloudflare account, tunnel, token scope, or public
  hostname
- real operator-owned registry, backup, edge, preview, or signing secret values
- failover, disaster recovery, and public route checks on non-original hardware
