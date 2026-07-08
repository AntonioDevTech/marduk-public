# Public Export Scan Report

Date: 2026-07-08
Update: refreshed after the Phase 11 deployability status update and OpenBao
first-install starter outline.

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
- `make doctor`, result: correctly reports that Go is missing in the local WSL
  shell. Public CI remains the test path until Go is installed locally.

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

Known safe generic values:

- The demo app uses a normal container HTTP port. That is application behavior,
  not private estate topology.
- The starter image name `registry.example.com/marduk/hello` and Go module
  `example.com/marduk/hello` are public placeholders.
