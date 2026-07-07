# Evidence Summary

This public export summarizes evidence without exposing private endpoints,
screenshots, topology, or credential metadata. The private repo retains the full
operator-grade logs and artifacts.

## Proven Privately

| Claim | Evidence shape |
|-------|----------------|
| Terraform rebuilds the VM layer | Timed apply output and node reachability checks |
| Talos boots a 3-node Kubernetes cluster | Node readiness and API checks |
| GitOps controls the platform | Git-to-cluster reconciliation timing and drift reversal |
| CI blocks vulnerable builds | Red build on a planted critical finding, then green after fix |
| CI signs deployable images | Signature verification against the public key |
| Admission denies unsigned images | Server-side dry-run and live denial tests |
| Secrets stay out of Git | Full-history leak scan plus vault-backed sync tests |
| Vault restore works | Fresh-vault snapshot restore and unseal drill |
| Network policy enforces default-deny | Audit-first rollout, would-drop review, then enforced tests |
| SLO alerts fire for real | Burn-rate and capacity alert tests with resolution proof |
| Node loss is survivable for the demo app | Load test during node kill, with SLO impact recorded |
| Pull-request previews work | Labelled PR creates a public preview and closes cleanly |
| Local AI review comments on PRs | Advisory review posted from a local model |

## Not Claimed Publicly

- Multi-hypervisor high availability.
- Disaster survival across independent power, disk, or site failures.
- A clean under-30-minute rebuild.
- That the public export is enough to operate the private estate.

## Rebuild Evidence Status

The platform has been rebuilt from destroyed VMs and recovered to green twice.
The latest timed rerun took 33m45s because it exposed a rebuild-only
network-policy staging bug. That bug is fixed, but one more clean rerun is
needed before claiming under 30 minutes.
