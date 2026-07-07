# Public Export Scan Report

Date: 2026-07-07
Update: refreshed after the public README rewrite, license addition, and starter
template expansion.

Scope:

```text
public-export/marduk-public
```

Automated checks run:

- gitleaks 8.28.0, `detect --no-git`, result: no leaks found.
- Private estate denylist grep for real domains, names, private IP ranges,
  hostnames, machine IDs, key fingerprints, and credential metadata, result:
  no real private values found.
- Private-key and common token-prefix grep, result: no hits.
- Markdown em dash check, result: no hits.

Manual boundary review:

- No private Git history is included.
- No screenshots or binary evidence artifacts are included.
- No Terraform state or operational Kubernetes manifests are included.
- No real domains, internal IPs, hostnames, usernames, credential identifiers, or
  custody locations are included.
- No personal legal name is included in the license.
- Starter templates use placeholders and documentation IP ranges only.

Known safe generic values:

- The demo app uses a normal container HTTP port. That is application behavior,
  not private estate topology.
