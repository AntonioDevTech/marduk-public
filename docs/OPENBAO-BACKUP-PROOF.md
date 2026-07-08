# OpenBao Backup Shipping Proof

Date: 2026-07-08

## Purpose

This proof checks the public backup seam without using any private MARDUK backup
host. It proves a disposable raft-backed OpenBao can create a real raft snapshot
and ship it to a disposable SSH receiver protected by a forced command.

## Public Helper Commit

```text
commit: a490685679a002438269558fd1f8eef61af66f27
workflow: ci
run: https://github.com/AntonioDevTech/marduk-public/actions/runs/28967552490
status: Success
```

## Command

```bash
make openbao-backup-proof
```

The command requires Docker, curl, python3, ssh, ssh-keygen, ssh-keyscan, and
sha256sum. It creates only disposable local resources and removes them before
exit.

## Safe Output

```text
Starting disposable OpenBao backup proof.
No real MARDUK infrastructure or secrets are used.
OpenBao disposable raft server: reachable
OpenBao disposable raft server: initialized and unsealed
OpenBao active leader: ready
OpenBao raft snapshot: saved
Disposable backup receiver: reachable
OpenBao backup proof: PASS
raft_snapshot_created=true snapshot_bytes=14721 snapshot_shipped=true remote_file=marduk-public-20260708185455.snap sha256_match=true forced_command_enforced=true negative_ssh_exit=1
seed_values_printed=false unseal_shares_printed=false vault_tokens_printed=false ssh_private_key_printed=false
```

The exact snapshot size and filename vary by run.

## What Was Proven

- A disposable `openbao/openbao:2.5.5` server started with raft storage.
- OpenBao initialized and unsealed without printing generated custody material.
- The helper waited until OpenBao reported active-leader health before writes.
- A real raft snapshot was saved from the OpenBao API.
- A disposable SSH backup receiver was built from `alpine:3.22`.
- The receiver allowed only a forced `recv-snapshot` command for the generated
  disposable ship key.
- The snapshot shipped over SSH to the receiver.
- The shipped snapshot byte count and sha256 matched the local snapshot.
- A negative SSH command request did not run arbitrary shell output.
- The root token, SSH private key, OpenBao container, receiver container, temp
  storage, and generated receiver image were removed after the proof.

## Clean Clone Proof

A fresh anonymous GitHub clone at commit
`a490685679a002438269558fd1f8eef61af66f27` passed:

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
  backup receiver container, or proof temp directory

## Still Not Proven

This does not yet prove:

- a user-owned real backup host, firewall rule, host key, or retention policy
- real operator-owned registry, backup, edge, preview, or signing secret values
- local public-edge route shape; that is covered by the separate
  `make public-edge-proof` command
- a user-owned real DNS zone, Cloudflare account, tunnel, token scope, or public
  hostname
- full Terraform/Talos/GitOps deployment on a random Proxmox host
- failover, disaster recovery, and public route checks on non-original hardware
