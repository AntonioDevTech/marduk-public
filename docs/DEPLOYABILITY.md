# Public Deployability

## Current Answer

This repository is public, cloneable, and useful as a starter.

It is not yet a turnkey public installer.

The private MARDUK operational repo has a proven deploy wrapper. This public repo
does not yet include a sanitized version of that wrapper. It does include
public-safe first-install OpenBao helper mechanics, but not the full backup and
public-edge first-install proof.

## What Works Today

- Anonymous GitHub clone.
- Local demo app source with `make test` support through either Go or Docker.
- Public config contract and starter doctor check.
- Public starter harness with `doctor`, `verify-config`, `plan`, and
  `render-terraform`, `openbao-plan`, `render-openbao`, and
  `openbao-first-install-dry-run`.
- Generated starter `terraform.tfvars` from a private `marduk.env` shape.
- Generated OpenBao first-install ACL policy and role payload bundle from a
  private `marduk.env` shape.
- Public CI for the demo app.
- Sanitized Terraform starter for three Proxmox/Talos VMs.
- Sanitized Talos patch examples.
- Sanitized Kubernetes starter manifests.
- Public-safe architecture and evidence summaries.
- Public-safe external gate and failover/DR proof matrices.
- Public-safe OpenBao first-install pattern, non-secret bootstrap bundle, and
  dry-run ceremony helper.
- Disposable OpenBao proof that the helper can initialize, unseal, apply the
  generated non-secret policies/roles, create AppRole credential files, submit
  Kubernetes auth config from a private mode-600 file, prove a real Kubernetes
  ServiceAccount login through kind, enforce policy scoping, install External
  Secrets into kind, sync OpenBao values into Kubernetes Secrets, seed
  public-safe registry and backup values through a mode-600 file, revoke root,
  verify post-root access, and remove the init JSON.
- Clean anonymous clone of the public repo passes starter checks and local
  container health proof.

## What A User Must Still Build Privately

- Real Proxmox endpoint, node name, storage, bridge, VLAN, gateway, and DNS plan.
- Real Terraform variables and state.
- Real Talos secrets and kubeconfig custody.
- Private Git host or GitHub/GitLab equivalent.
- Registry and signing identity.
- OpenBao first-install custody, saved AppRole credential custody, real
  Kubernetes auth material, and initial secrets.
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
4. Render OpenBao first-install policy and role payload bundle. DONE.
5. Prove OpenBao helper mechanics against disposable resources. DONE for
   init/unseal/apply generated bundle/AppRole credential files/Kubernetes auth
   config submission/real ServiceAccount login/policy scoping/External Secrets
   sync/public-safe registry and backup seed/root revoke/post-root access, not
   real operator-owned secret values.
6. Expand the public starter harness into real deploy orchestration.
7. Add a live-tested first-install OpenBao path for users with no existing vault
   snapshot.
8. Run an independent Proxmox proof on non-Antonio infrastructure if available.
9. Summarize failover and disaster-recovery claims with public-safe evidence.
10. Re-run secret scans and private-value denylist scans on the final public repo.

Until those pass, the honest claim is:

```text
MARDUK is a public starter and a private proven implementation.
It is not yet a public turnkey installer.
```
