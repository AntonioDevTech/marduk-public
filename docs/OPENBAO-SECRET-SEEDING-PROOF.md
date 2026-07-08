# OpenBao Runtime Secret Seeding Proof

Date: 2026-07-08

## Purpose

This proof checks the public first-install seam after External Secrets sync:
the public helper can seed runtime secret paths from a mode-600 JSON file, then
External Secrets can materialize those seeded values into Kubernetes Secrets.

The proof uses public-safe fake values only.

## Public Helper Commit

```text
commit: 82d400dbf1fb36b55ef69a10b7d7c4cdca3f2978
workflow: ci
run: public GitHub Actions run 28966509399
status: Success
```

## Command

```bash
make openbao-secret-seeding-proof
```

The command requires Docker, kind, kubectl, Helm, curl, python3, and base64. It
creates only disposable local resources and removes them before exit.

## Safe Output

```text
Starting disposable OpenBao secret seeding proof.
No real MARDUK infrastructure or secrets are used.
Disposable Kubernetes cluster: ready
OpenBao disposable server: reachable
initialized=False sealed=True threshold=0 shares=0 progress=0
OpenBao disposable server: initialized and unsealed
OpenBao bootstrap bundle: applied
External Secrets Operator: installed
OpenBao Kubernetes auth config: applied
OpenBao public-safe seed file: applied
Public-safe secret seeding proof: PASS
kind_cluster_created=true external_secrets_installed=true clustersecretstore_ready=true seeded_prefixes=registry,backup externalsecrets_synced=true target_secrets_verified=true
seed_values_printed=false unseal_shares_printed=false token_reviewer_jwt_printed=false service_account_jwt_printed=false vault_tokens_printed=false
```

## What Was Proven

- A disposable kind cluster became ready.
- A disposable OpenBao `openbao/openbao:2.5.5` server started fresh, then was
  initialized and unsealed without printing generated custody material.
- The generated public OpenBao bootstrap bundle applied successfully.
- External Secrets chart `2.7.0` installed successfully into kind.
- OpenBao Kubernetes auth was configured with a real reviewer JWT and cluster CA
  from the disposable kind cluster.
- The `seed-runtime-secrets` helper accepted only a mode-600 seed file.
- The helper validated seed paths against `OPENBAO_RUNTIME_SECRET_PREFIXES`.
- Public-safe fake registry and backup values were written to disposable
  OpenBao.
- A `ClusterSecretStore` became Ready.
- Two `ExternalSecret` resources became Ready.
- The target Kubernetes Secrets contained the expected public-safe fake values.
- The root token, kind cluster, OpenBao container, and temp storage were removed
  after the proof.

## Clean Clone Proof

A fresh anonymous GitHub clone at commit
`82d400dbf1fb36b55ef69a10b7d7c4cdca3f2978` passed:

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
- `make openbao-backup-proof`
- `git diff --check`
- gitleaks 8.28.0 with no leaks
- private-value denylist scan with no hits
- cleanup checks showing no leftover disposable kind cluster, OpenBao container,
  or proof temp directory

## Still Not Proven

This does not yet prove:

- real operator-owned registry, backup, edge, preview, or signing secret values
- public-clean backup shipping is covered by the separate
  `make openbao-backup-proof` command
- a user-owned real backup host, firewall rule, host key, or retention policy
- full Terraform/Talos/GitOps deployment on a random Proxmox host
- failover, disaster recovery, and public route checks on non-original hardware
