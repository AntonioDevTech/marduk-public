# Public Deployability

## Current Answer

This repository is public, cloneable, and useful as a starter.

It is not yet a turnkey public installer.

The private MARDUK operational repo has a proven deploy wrapper. This public repo
does not yet include a sanitized version of that wrapper or the first-install
OpenBao ceremony.

## What Works Today

- Anonymous GitHub clone.
- Local demo app source.
- Public CI for the demo app.
- Sanitized Terraform starter for three Proxmox/Talos VMs.
- Sanitized Talos patch examples.
- Sanitized Kubernetes starter manifests.
- Public-safe architecture and evidence summaries.
- Public-safe OpenBao first-install pattern.

## What A User Must Still Build Privately

- Real Proxmox endpoint, node name, storage, bridge, VLAN, gateway, and DNS plan.
- Real Terraform variables and state.
- Real Talos secrets and kubeconfig custody.
- Private Git host or GitHub/GitLab equivalent.
- Registry and signing identity.
- OpenBao first-install custody, policies, AppRoles, and initial secrets.
- Backup target and snapshot shipping path.
- External DNS/public edge model.
- Out-of-band observability.
- Firewall rules and packet proofs.

## Proof Ladder Before "Clone And Deploy"

1. Publish a sanitized operational package with estate-specific values moved to
   documented example config files.
2. Add a first-install OpenBao path for users with no existing vault snapshot.
3. Run a clean-room clone proof with only documented inputs.
4. Run an independent Proxmox proof on non-Antonio infrastructure if available.
5. Summarize failover and disaster-recovery claims with public-safe evidence.
6. Re-run secret scans and private-value denylist scans on the final public repo.

Until those pass, the honest claim is:

```text
MARDUK is a public starter and a private proven implementation.
It is not yet a public turnkey installer.
```
