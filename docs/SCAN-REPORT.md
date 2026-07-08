# Public Export Scan Report

Date: 2026-07-08
Update: refreshed after the Phase 11 deployability status update, OpenBao
first-install starter outline, Docker fallback test path, starter config doctor,
and public starter harness.

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
- Negative starter-doctor check, result: PASS because the example config is
  rejected without `--allow-placeholders`.
- `make docker-build`, result: PASS.
- Local container health probe, result: `/healthz` returned HTTP 200.
- `./deploy-marduk-public.sh doctor`, result: PASS.
- `./deploy-marduk-public.sh plan`, result: PASS and prints the staged public
  deploy path.
- `./deploy-marduk-public.sh deploy`, result: expected pause because public
  turnkey deploy is not implemented yet.

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
- Public deploy harness is non-destructive and refuses to claim full deploy.

Known safe generic values:

- The demo app uses a normal container HTTP port. That is application behavior,
  not private estate topology.
- The starter image name `registry.example.com/marduk/hello` and Go module
  `example.com/marduk/hello` are public placeholders.
