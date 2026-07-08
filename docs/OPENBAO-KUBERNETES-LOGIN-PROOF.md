# OpenBao Kubernetes Login Proof

Date: 2026-07-08

## Purpose

This proof checks the first real Kubernetes identity seam in the public starter.
It proves more than submitting OpenBao Kubernetes auth config: a real Kubernetes
ServiceAccount JWT from a disposable kind cluster can log into disposable
OpenBao and can read only the policy path it is allowed to read.

## Public Helper Commit

```text
commit: ccc399ae3f8bbf4f285d9177ae9e9e9d4e613006
workflow: ci
run: https://github.com/AntonioDevTech/marduk-public/actions/runs/28963090512
status: Success
```

## Command

```bash
make openbao-kubernetes-login-proof
```

The command requires Docker, kind, kubectl, curl, python3, and base64. It creates
only disposable local resources and removes them before exit.

## Safe Output

```text
Starting disposable kind cluster and OpenBao Kubernetes-auth login proof.
No real MARDUK infrastructure or secrets are used.
Disposable Kubernetes cluster: ready
OpenBao disposable server: reachable
initialized=False sealed=True threshold=0 shares=0 progress=0
OpenBao disposable server: initialized and unsealed
OpenBao bootstrap bundle: applied
OpenBao Kubernetes auth config: applied
OpenBao Kubernetes auth login: accepted
OpenBao Kubernetes login proof: PASS
kind_cluster_created=true kubernetes_auth_login=true policy_read_allowed=true policy_cross_path_denied=true
token_reviewer_jwt_printed=false service_account_jwt_printed=false vault_tokens_printed=false
```

## What Was Proven

- A disposable kind cluster became ready.
- A disposable OpenBao `openbao/openbao:2.5.5` server started fresh, then was
  initialized and unsealed without printing generated custody material.
- The generated public OpenBao bootstrap bundle applied successfully.
- Kubernetes auth was configured with a real reviewer JWT and cluster CA from
  the disposable kind cluster.
- A real `external-secrets/external-secrets` ServiceAccount JWT logged into
  OpenBao through the `eso` role.
- The resulting OpenBao token read an allowed `marduk/data/registry/*` proof
  secret.
- The same token received HTTP 403 on the denied `marduk/data/ci/cosign` path.
- OpenBao tokens, the kind cluster, the OpenBao container, and temp storage were
  removed after the proof.

## Clean Clone Proof

A fresh anonymous GitHub clone at commit
`ccc399ae3f8bbf4f285d9177ae9e9e9d4e613006` passed:

- shell syntax for `deploy-marduk-public.sh` and all starter scripts
- `make doctor`
- Docker-backed `make test`
- `make starter-doctor`
- `make public-plan`
- `make starter-tfvars`
- `make openbao-plan`
- `make openbao-bootstrap`
- `make openbao-first-install-dry-run`
- `make docker-build`
- `make openbao-kubernetes-login-proof`
- `git diff --check`
- gitleaks 8.28.0 with no leaks
- private-value denylist scan with no hits

## Still Not Proven

This proof by itself does not prove:

- ESO controller sync; that is covered by the separate
  `make openbao-eso-sync-proof` command
- public-safe registry and backup seed sync; that is covered by the separate
  `make openbao-secret-seeding-proof` command
- real operator-owned registry, backup, edge, preview, or signing secret values
- first off-cluster backup in a public clean-room environment
- full Terraform/Talos/GitOps deployment on a random Proxmox host
- failover, disaster recovery, and public route checks on non-original hardware
