# Public Edge Route Proof

Date: 2026-07-08

## Purpose

This proof checks the public edge route shape without using a real DNS zone,
Cloudflare account, tunnel token, or public hostname. It proves the demo app can
sit behind a disposable edge proxy that routes by hostname and rejects unknown
hostnames.

## Public Helper Commit

```text
commit: bc694d5e708b1282aefd4ba06b5c57139a3ca55f
workflow: ci
run: https://github.com/AntonioDevTech/marduk-public/actions/runs/28968458395
status: Success
```

## Command

```bash
make public-edge-proof
```

The command requires Docker and curl. It creates only disposable local resources
and removes them before exit.

## Safe Output

```text
Starting disposable public-edge proof.
No real DNS, Cloudflare account, tunnel token, or public route is used.
Public-edge proof: PASS
hello_host=hello.example.invalid hello_http=200 healthz_http=200 healthz_body=ok unknown_host_http=404 edge_proxy=pinned-nginx tunnel_tokens_used=false dns_tokens_used=false
```

## What Was Proven

- The public demo app container built successfully.
- The demo app ran behind a disposable pinned Nginx edge proxy.
- A request with `Host: hello.example.invalid` returned HTTP 200.
- `/healthz` through the edge proxy returned HTTP 200 and body `ok`.
- A request with an unknown hostname returned HTTP 404.
- No DNS token, Cloudflare token, tunnel credential, or real public hostname was
  used.
- The disposable containers, Docker network, generated app image, and temp files
  were removed after the proof.

## Clean Clone Proof

A fresh anonymous GitHub clone at commit
`bc694d5e708b1282aefd4ba06b5c57139a3ca55f` passed:

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
- `make public-edge-proof`
- `git diff --check`
- gitleaks 8.28.0 with no leaks
- private-value denylist scan with no hits
- cleanup checks showing no leftover disposable kind cluster, OpenBao container,
  backup receiver container, edge proxy container, Docker network, or proof temp
  directory

## Still Not Proven

This does not yet prove:

- a user-owned real DNS zone, Cloudflare account, tunnel, token scope, or public
  hostname
- real operator-owned registry, backup, edge, preview, or signing secret values
- full Terraform/Talos/GitOps deployment on a random Proxmox host
- failover, disaster recovery, and public route checks on non-original hardware
