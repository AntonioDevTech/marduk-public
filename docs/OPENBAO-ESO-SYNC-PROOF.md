# OpenBao External Secrets Sync Proof

Date: 2026-07-08

## Purpose

This proof checks the next public first-install seam after Kubernetes auth login:
External Secrets Operator can use OpenBao Kubernetes auth to materialize a
Kubernetes Secret from a value stored in OpenBao.

## Public Helper Commit

```text
commit: d2b655d83cc31d7e37eb37da8d233ae7aa9f1ba2
workflow: ci
run: https://github.com/AntonioDevTech/marduk-public/actions/runs/28964935158
status: Success
```

## Command

```bash
make openbao-eso-sync-proof
```

The command requires Docker, kind, kubectl, Helm, curl, python3, and base64. It
creates only disposable local resources and removes them before exit.

## Safe Output

```text
Starting disposable External Secrets and OpenBao sync proof.
No real MARDUK infrastructure or secrets are used.
Disposable Kubernetes cluster: ready
OpenBao disposable server: reachable
initialized=False sealed=True threshold=0 shares=0 progress=0
OpenBao disposable server: initialized and unsealed
OpenBao bootstrap bundle: applied
External Secrets Operator: installed
OpenBao Kubernetes auth config: applied
OpenBao proof secret: written
External Secrets sync proof: PASS
kind_cluster_created=true external_secrets_installed=true clustersecretstore_ready=true externalsecret_synced=true target_secret_verified=true
unseal_shares_printed=false token_reviewer_jwt_printed=false service_account_jwt_printed=false vault_tokens_printed=false
```

## What Was Proven

- A disposable kind cluster became ready.
- A disposable OpenBao `openbao/openbao:2.5.5` server started fresh, then was
  initialized and unsealed without printing generated custody material.
- The generated public OpenBao bootstrap bundle applied successfully.
- External Secrets chart `2.7.0` installed successfully into kind.
- OpenBao Kubernetes auth was configured with a real reviewer JWT and cluster CA
  from the disposable kind cluster.
- A proof value was written to `marduk/data/registry/proof` in disposable
  OpenBao.
- A `ClusterSecretStore` became Ready.
- An `ExternalSecret` became Ready.
- The target Kubernetes Secret contained the expected value from OpenBao.
- The root token, kind cluster, OpenBao container, and temp storage were removed
  after the proof.

## Clean Clone Proof

A fresh anonymous GitHub clone at commit
`d2b655d83cc31d7e37eb37da8d233ae7aa9f1ba2` passed:

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
- `make openbao-eso-sync-proof`
- `make openbao-secret-seeding-proof`
- `git diff --check`
- gitleaks 8.28.0 with no leaks
- private-value denylist scan with no hits

## Still Not Proven

This does not yet prove:

- real operator-owned registry, backup, edge, preview, or signing secret values
- public-safe registry and backup seeding is covered by
  `make openbao-secret-seeding-proof`
- public-clean backup shipping; that is covered by the separate
  `make openbao-backup-proof` command
- a user-owned real backup host, firewall rule, host key, or retention policy
- full Terraform/Talos/GitOps deployment on a random Proxmox host
- failover, disaster recovery, and public route checks on non-original hardware
