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
| Private wrapper rebuilds under 10 minutes | Destroyed-VM rebuild transcripts with final verifier output |
| Pull-request previews work | Labelled PR creates a public preview and closes cleanly |
| Local AI review comments on PRs | Advisory review posted from a local model |

## Not Claimed Publicly

- Multi-hypervisor high availability.
- Disaster survival across independent power, disk, or site failures.
- That the public export is enough to operate the private estate unchanged.
- That a random Proxmox user can deploy the full platform from this public repo
  without a future sanitized operational package.

## Rebuild Evidence Status

The private platform has been rebuilt from destroyed VMs and recovered to green
multiple times. The final Phase 11 wrapper proofs completed in under 10 minutes
from safe prep start and finished with strict platform verification.

Separate status: the public repo is cloneable and safe, but it is still a
starter. A clean-room public deploy proof is not complete.
