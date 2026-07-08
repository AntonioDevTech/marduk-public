# Public Deployability

## Current Answer

This repository is public, cloneable, and useful as a starter.

It is not yet a turnkey public installer.

The private MARDUK operational repo has a proven deploy wrapper. This public repo
does not yet include a sanitized version of that wrapper or the first-install
OpenBao ceremony.

## What Works Today

- Anonymous GitHub clone.
- Local demo app source with `make test` support through either Go or Docker.
- Public config contract and starter doctor check.
- Public starter harness with `doctor`, `verify-config`, `plan`, and
  `render-terraform`.
- Generated starter `terraform.tfvars` from a private `marduk.env` shape.
- Public CI for the demo app.
- Sanitized Terraform starter for three Proxmox/Talos VMs.
- Sanitized Talos patch examples.
- Sanitized Kubernetes starter manifests.
- Public-safe architecture and evidence summaries.
- Public-safe external gate and failover/DR proof matrices.
- Public-safe OpenBao first-install pattern.
- Clean anonymous clone of the public repo passes starter checks and local
  container health proof.

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
   documented example config files. The first public config contract now exists.
2. Prove public starter checks from a clean anonymous clone. DONE for local
   starter checks, not full Proxmox deploy.
3. Render concrete deploy-plan and Terraform starter inputs from user-supplied
   config. DONE for starter inputs, not Terraform apply.
4. Expand the public starter harness into real deploy orchestration.
5. Add a first-install OpenBao path for users with no existing vault snapshot.
6. Run an independent Proxmox proof on non-Antonio infrastructure if available.
7. Summarize failover and disaster-recovery claims with public-safe evidence.
8. Re-run secret scans and private-value denylist scans on the final public repo.

Until those pass, the honest claim is:

```text
MARDUK is a public starter and a private proven implementation.
It is not yet a public turnkey installer.
```
