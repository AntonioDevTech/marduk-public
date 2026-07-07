# Public Safety Boundary

This export is designed to be safe to publish as a portfolio artifact.

## Included

- Sanitized architecture.
- Public-safe capability summary.
- Public-safe evidence summary.
- Honest rebuild status.
- Small demo service source.
- Sanitized starter templates for Terraform, Talos, Kubernetes, and security
  policy.
- LinkedIn launch copy.

## Excluded

- Private Git history.
- Terraform state or provider configuration.
- Kubernetes manifests from the operational estate. Public starter manifests use
  placeholders only.
- Internal domains, hostnames, usernames, IP ranges, port maps, and device names.
- Credential names, token names, key fingerprints, secret paths, and custody
  locations.
- Screenshots and binary artifacts.
- Session logs, troubleshooting logs, incident logs, and recovery runbooks.

## Before Publishing Elsewhere

Run a fresh scan on the final public repo or archive:

- Search for private IP ranges.
- Search for real domains and usernames.
- Search for private key blocks.
- Search for common token prefixes.
- Manually inspect images and PDFs if any are added.
- Confirm the repo has no private operational history.

The operational MARDUK repo should remain private.
