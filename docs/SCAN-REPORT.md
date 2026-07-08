# Public Export Scan Report

Date: 2026-07-08
Update: refreshed after the Phase 11 deployability status update, OpenBao
first-install starter outline, Docker fallback test path, starter config doctor,
public starter harness, generated deploy plan, generated Terraform starter
inputs, generated OpenBao first-install bootstrap bundle, and OpenBao
first-install dry-run helper, AppRole credential file helper, Kubernetes auth
config helper, Kubernetes login proof, External Secrets sync proof, and
runtime secret seed helper, public-clean backup proof, and post-root access
verifier.

Scope:

```text
public-export/marduk-public
```

Automated checks run:

- gitleaks 8.28.0 via Docker,
  `detect --no-git --source /src --redact`, result: no leaks found.
- Private estate denylist grep for real domains, names, private IP ranges,
  hostnames, machine IDs, key fingerprints, and credential metadata, result:
  no real private values found. Generic placeholder hits such as
  `example.com/marduk/hello` are expected and public-safe.
- Private-key and common token-prefix grep, result: no hits.
- `git diff --check`, result: clean.
- `make doctor`, result: PASS with Docker fallback because local Go is not
  installed in the WSL shell.
- `make test`, result: PASS through `golang:1.26-alpine`.
- `make starter-doctor`, result: PASS for the public example config with
  placeholders explicitly allowed.
- `make public-plan`, result: PASS and renders a config-derived staged deploy
  plan.
- `make starter-tfvars`, result: PASS and renders starter Terraform variables.
- `make openbao-plan`, result: PASS and renders the public first-install gate
  plan.
- `make openbao-bootstrap`, result: PASS and renders ACL policies plus role
  payloads to `/tmp/marduk-openbao-bootstrap`.
- `make openbao-first-install-dry-run`, result: PASS and prints the public-safe
  first-install ceremony without contacting OpenBao or printing secrets.
- `make openbao-secret-seeding-proof`, result: PASS and proves public-safe
  registry and backup seed values sync through disposable OpenBao, kind, and
  External Secrets.
- `make openbao-backup-proof`, result: PASS and proves a real disposable OpenBao
  raft snapshot ships to a disposable forced-command SSH receiver with a matching
  sha256.
- Negative OpenBao init-refusal check, result: PASS because
  `starter/scripts/openbao-first-install.sh init` refuses to run without the
  explicit `--i-understand-this-prints-tier0-shares` flag.
- Negative starter-doctor check, result: PASS because the example config is
  rejected without `--allow-placeholders`.
- Real-looking private config proof in `/tmp`, result: PASS for
  `verify-config`, `plan`, `render-terraform`, `terraform fmt -check` on the
  generated tfvars, `openbao-plan`, `render-openbao`, and expected `deploy`
  pause.
- `make docker-build`, result: PASS.
- Local container health probe, result: `/healthz` returned HTTP 200.
- `./deploy-marduk-public.sh doctor`, result: PASS.
- `./deploy-marduk-public.sh plan`, result: PASS and prints the staged public
  deploy path.
- `./deploy-marduk-public.sh render-terraform`, result: PASS and prints HCL
  starter variables from the example config.
- `./deploy-marduk-public.sh openbao-plan`, result: PASS and prints the
  first-install custody gate plan.
- `./deploy-marduk-public.sh render-openbao`, result: PASS and writes
  non-secret OpenBao policy and role payload files.
- `./deploy-marduk-public.sh openbao-first-install-dry-run`, result: PASS.
- `./deploy-marduk-public.sh deploy`, result: expected pause because public
  turnkey deploy is not implemented yet.
- Published GitHub clean clone proof at
  `211c859efe7494bedf80f13022896fab319c1253`, result: `make doctor`,
  `make test`, `make starter-doctor`, `./deploy-marduk-public.sh plan`,
  `make docker-build`, and container `/healthz` HTTP 200 all passed.
- Public GitHub Actions for the same commit, result: completed success.
- Published GitHub generated-plan proof at
  `ad072ed22853b667ebc4d2b155382d43b56de84d`, result: `make doctor`,
  `make test`, `make starter-doctor`, `make public-plan`,
  `make starter-tfvars`, `make docker-build`, clean-clone gitleaks, private
  denylist grep, and container `/healthz` HTTP 200 all passed.
- Public GitHub Actions for commit `ad072ed22853b667ebc4d2b155382d43b56de84d`,
  result: completed success in 47s,
  `https://github.com/AntonioDevTech/marduk-public/actions/runs/28935126147`.
- Published GitHub OpenBao-bundle proof at
  `bc285ddfa1b481c8de787bcfc187e451052cd688`, result: `make doctor`,
  `make test`, `make starter-doctor`, `make public-plan`,
  `make starter-tfvars`, `make openbao-plan`, `make openbao-bootstrap`,
  `make docker-build`, clean-clone gitleaks, refined private denylist grep, and
  container `/healthz` HTTP 200 all passed.
- Public GitHub Actions for commit `bc285ddfa1b481c8de787bcfc187e451052cd688`,
  result: completed success,
  `https://github.com/AntonioDevTech/marduk-public/actions/runs/28937020279`.
- Published GitHub OpenBao first-install dry-run proof at
  `3447c596c2e5b302bd20c01a62dd2467b091f68f`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  OpenBao init-refusal negative check, `make docker-build`, standalone repo
  gitleaks, refined private denylist grep, and container `/healthz` HTTP 200
  all passed.
- Public GitHub Actions for commit `3447c596c2e5b302bd20c01a62dd2467b091f68f`,
  result: completed success,
  `https://github.com/AntonioDevTech/marduk-public/actions/runs/28937684741`.
- Anonymous clean clone proof for
  `3447c596c2e5b302bd20c01a62dd2467b091f68f`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  OpenBao init-refusal negative check, `make docker-build`, container
  `/healthz` HTTP 200, gitleaks, and refined private denylist grep all passed.
- Disposable OpenBao live-helper proof against `openbao/openbao:2.5.5`, result:
  `starter/scripts/openbao-first-install.sh preflight`, `status`, guarded
  `init`, `unseal`, final `status`, and `shred-init` all passed against a fresh
  local file-storage vault on a temporary Docker port. Init output and unseal
  input were redirected to private temp files, never printed, and shredded.
  The disposable vault container and root-owned temp storage were removed.
- Disposable OpenBao bootstrap-apply proof against `openbao/openbao:2.5.5`,
  result: rendered the non-secret bundle, initialized and unsealed a fresh local
  vault, ran `apply-bootstrap`, verified KV mount, Kubernetes auth, AppRole auth,
  four ACL policies, four roles, ran `revoke-root`, confirmed root lookup
  returned HTTP 403, removed the init JSON, shredded temp custody files, and
  removed the disposable container/storage.
- Disposable OpenBao post-root proof against `openbao/openbao:2.5.5`, result:
  rendered the non-secret bundle, initialized and unsealed a fresh local vault,
  ran `apply-bootstrap`, created two AppRole credential files with mode 600
  without printing role IDs or secret IDs, ran `revoke-root`, verified root
  lookup returned HTTP 403, logged in through the saved admin AppRole file, wrote,
  read, and deleted a throwaway KV secret, revoked the transient AppRole token,
  removed the init JSON, and removed disposable storage.
- Disposable OpenBao Kubernetes-auth proof against `openbao/openbao:2.5.5`,
  result: generated a temporary mode-600 Kubernetes auth JSON file with
  throwaway reviewer JWT and generated CA content, submitted it through
  `configure-kubernetes-auth`, verified OpenBao readback contained host and CA,
  printed only booleans, then revoked root and verified post-root admin access.
- Disposable OpenBao Kubernetes-login proof against `openbao/openbao:2.5.5` and
  kind, result: created a disposable kind cluster, created reviewer and
  external-secrets service accounts, configured OpenBao Kubernetes auth with a
  real reviewer JWT and cluster CA, logged in with a real external-secrets
  ServiceAccount JWT, read an allowed `registry/` proof secret, confirmed the
  same token received HTTP 403 on the denied `ci/cosign` path, revoked tokens,
  and removed the disposable cluster, container, and temp storage.
- Disposable External Secrets sync proof against `openbao/openbao:2.5.5`, kind,
  and External Secrets chart 2.7.0, result: installed ESO into a disposable kind
  cluster, configured a ClusterSecretStore against disposable OpenBao, created an
  ExternalSecret for `registry/proof`, waited for the store and ExternalSecret
  to become Ready, verified the target Kubernetes Secret contained the expected
  value, revoked root, and removed the disposable cluster, container, and temp
  storage.
- Disposable runtime secret seeding proof against `openbao/openbao:2.5.5`, kind,
  and External Secrets chart 2.7.0, result: created a mode-600 seed file with
  public-safe fake values, ran `seed-runtime-secrets`, wrote `registry/` and
  `backup/` proof values to disposable OpenBao, synced both into Kubernetes
  Secrets through External Secrets, verified the target values, revoked root,
  and removed the disposable cluster, container, and temp storage.
- Disposable OpenBao backup proof against `openbao/openbao:2.5.5`, result:
  started a raft-backed disposable OpenBao, initialized/unsealed it without
  printing shares, waited for active-leader health, saved a real raft snapshot,
  built a disposable `alpine:3.22` SSH receiver with a forced `recv-snapshot`
  command, shipped the snapshot over SSH, verified remote byte count and sha256
  matched, proved arbitrary SSH command output did not run, revoked root, and
  removed the disposable containers, image, key, and temp storage.
- Published GitHub OpenBao bootstrap-apply helper commit
  `ecf3ca1cac2dbb15c0c09a7b27d79dfe2bad0889`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  OpenBao init-refusal negative check, `make docker-build`, standalone repo
  gitleaks, refined private denylist grep, and container `/healthz` HTTP 200
  all passed.
- Public GitHub Actions for commit `ecf3ca1cac2dbb15c0c09a7b27d79dfe2bad0889`,
  result: completed success,
  `https://github.com/AntonioDevTech/marduk-public/actions/runs/28938776164`.
- Anonymous clean clone proof for
  `ecf3ca1cac2dbb15c0c09a7b27d79dfe2bad0889`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  OpenBao init-refusal negative check, `make docker-build`, container
  `/healthz` HTTP 200, gitleaks, and refined private denylist grep all passed.
- Published GitHub OpenBao post-root helper commit
  `e21e1dd86afa0d27b64545d0c8c70d70ed7d6b6f`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  OpenBao init-refusal negative check, `make docker-build`, container
  `/healthz` HTTP 200, standalone repo gitleaks, refined private denylist grep,
  and disposable OpenBao post-root proof all passed.
- Public GitHub Actions for commit `e21e1dd86afa0d27b64545d0c8c70d70ed7d6b6f`,
  result: completed success,
  `https://github.com/AntonioDevTech/marduk-public/actions/runs/28960714242`.
- Anonymous clean clone proof for
  `e21e1dd86afa0d27b64545d0c8c70d70ed7d6b6f`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  OpenBao init-refusal negative check, `make docker-build`, container
  `/healthz` HTTP 200, gitleaks, refined private denylist grep, and disposable
  OpenBao post-root proof all passed.
- Published GitHub OpenBao Kubernetes-auth helper commit
  `44dc22580d9b809d31b9082aeec30141733afc8a`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  OpenBao init-refusal negative check, `make docker-build`, container
  `/healthz` HTTP 200, standalone repo gitleaks, refined private denylist grep,
  and disposable OpenBao Kubernetes-auth proof all passed.
- Public GitHub Actions for commit `44dc22580d9b809d31b9082aeec30141733afc8a`,
  result: completed success,
  `https://github.com/AntonioDevTech/marduk-public/actions/runs/28961357865`.
- Anonymous clean clone proof for
  `44dc22580d9b809d31b9082aeec30141733afc8a`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  OpenBao init-refusal negative check, `make docker-build`, container
  `/healthz` HTTP 200, gitleaks, refined private denylist grep, and disposable
  OpenBao Kubernetes-auth proof all passed.
- Published GitHub OpenBao Kubernetes-login helper commit
  `ccc399ae3f8bbf4f285d9177ae9e9e9d4e613006`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  `make docker-build`, `make openbao-kubernetes-login-proof`, `git diff --check`,
  standalone repo gitleaks, refined private denylist grep, and cleanup checks all
  passed.
- Public GitHub Actions for commit `ccc399ae3f8bbf4f285d9177ae9e9e9d4e613006`,
  result: completed success,
  `https://github.com/AntonioDevTech/marduk-public/actions/runs/28963090512`.
- Anonymous clean clone proof for
  `ccc399ae3f8bbf4f285d9177ae9e9e9d4e613006`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  `make docker-build`, `make openbao-kubernetes-login-proof`, `git diff --check`,
  gitleaks, refined private denylist grep, and cleanup checks all passed.
- Published GitHub OpenBao ESO sync helper commit
  `d2b655d83cc31d7e37eb37da8d233ae7aa9f1ba2`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  `make docker-build`, `make openbao-kubernetes-login-proof`,
  `make openbao-eso-sync-proof`, `git diff --check`, standalone repo gitleaks,
  refined private denylist grep, and cleanup checks all passed.
- Public GitHub Actions for commit `d2b655d83cc31d7e37eb37da8d233ae7aa9f1ba2`,
  result: completed success,
  `https://github.com/AntonioDevTech/marduk-public/actions/runs/28964935158`.
- Anonymous clean clone proof for
  `d2b655d83cc31d7e37eb37da8d233ae7aa9f1ba2`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  `make docker-build`, `make openbao-kubernetes-login-proof`,
  `make openbao-eso-sync-proof`, `git diff --check`, gitleaks, refined private
  denylist grep, and cleanup checks all passed.
- Published GitHub OpenBao runtime secret seeding helper commit
  `82d400dbf1fb36b55ef69a10b7d7c4cdca3f2978`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  `make docker-build`, `make openbao-kubernetes-login-proof`,
  `make openbao-eso-sync-proof`, `make openbao-secret-seeding-proof`,
  `git diff --check`, standalone repo gitleaks, refined private denylist grep,
  and cleanup checks all passed.
- Public GitHub Actions for commit `82d400dbf1fb36b55ef69a10b7d7c4cdca3f2978`,
  result: completed success,
  `https://github.com/AntonioDevTech/marduk-public/actions/runs/28966509399`.
- Anonymous clean clone proof for
  `82d400dbf1fb36b55ef69a10b7d7c4cdca3f2978`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  `make docker-build`, `make openbao-kubernetes-login-proof`,
  `make openbao-eso-sync-proof`, `make openbao-secret-seeding-proof`,
  `git diff --check`, gitleaks, refined private denylist grep, and cleanup
  checks all passed.
- Published GitHub OpenBao backup helper commit
  `a490685679a002438269558fd1f8eef61af66f27`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  `make docker-build`, `make openbao-kubernetes-login-proof`,
  `make openbao-eso-sync-proof`, `make openbao-secret-seeding-proof`,
  `make openbao-backup-proof`, `git diff --check`, standalone repo gitleaks,
  refined private denylist grep, and cleanup checks all passed.
- Public GitHub Actions for commit `a490685679a002438269558fd1f8eef61af66f27`,
  result: completed success,
  `https://github.com/AntonioDevTech/marduk-public/actions/runs/28967552490`.
- Anonymous clean clone proof for
  `a490685679a002438269558fd1f8eef61af66f27`, result: shell syntax,
  `make doctor`, Docker-backed `make test`, `make starter-doctor`,
  `make public-plan`, `make starter-tfvars`, `make openbao-plan`,
  `make openbao-bootstrap`, `make openbao-first-install-dry-run`,
  `make docker-build`, `make openbao-kubernetes-login-proof`,
  `make openbao-eso-sync-proof`, `make openbao-secret-seeding-proof`,
  `make openbao-backup-proof`, `git diff --check`, gitleaks, refined private
  denylist grep, and cleanup checks all passed.

Manual boundary review:

- No private Git history is included.
- No screenshots or binary evidence artifacts are included.
- No Terraform state or private operational Kubernetes manifests are included.
- No real domains, internal IPs, hostnames, usernames, credential identifiers, or
  custody locations are included.
- No personal legal name is included in the license.
- Starter templates use placeholders and documentation IP ranges only.
- Public docs now state that this repo is a starter, not a turnkey installer.
- Public OpenBao material is an outline only; no live paths, shares, root token,
  AppRole values, or secret values are included.
- Public config material is sourceable example data only; real topology and
  secret values remain private user inputs.
- Public generated Terraform variables are starter outputs only; real generated
  `terraform.tfvars` is ignored and belongs in a private operational repo.
- Public generated OpenBao bootstrap files contain ACL policies and role
  payloads only; real shares, root tokens, AppRole secret IDs, signing keys,
  registry passwords, DNS tokens, and backup keys stay private.
- Public OpenBao first-install helper dry-runs safely and refuses live init
  unless a human passes the explicit custody-warning flag.
- Disposable live-helper proof now covers init/unseal, generated policy and role
  apply, AppRole credential file creation, Kubernetes auth config submission,
  real Kubernetes ServiceAccount JWT login, policy scoping, External Secrets
  sync, public-safe registry and backup seed, root revoke, and post-root admin
  access mechanics. It also proves disposable raft snapshot shipping through a
  forced-command SSH receiver. It does not publish real operator-owned secret
  values, prove a user-owned backup target, prove public-edge paths, or replace
  the need for a clean public Proxmox first-install proof.
- Public deploy harness is non-destructive and refuses to claim full deploy.
- Clean clone proof covers the public starter only, not full Proxmox deployment.

Known safe generic values:

- The demo app uses a normal container HTTP port. That is application behavior,
  not private estate topology.
- The starter image name `registry.example.com/marduk/hello` and Go module
  `example.com/marduk/hello` are public placeholders.
