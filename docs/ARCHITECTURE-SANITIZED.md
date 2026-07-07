# Architecture, Sanitized

MARDUK models a managed-cloud Internal Developer Platform inside a homelab. The
architecture is built around one rule: after bootstrap, the platform changes only
through Git.

The private implementation uses real infrastructure names and addresses. This
public version replaces them with roles and boundaries.

## Control Loops

1. A developer pushes to the private source repository.
2. CI builds the demo image, generates an SBOM, scans it, signs it, and writes
   back the immutable digest.
3. GitOps reconciles the desired state from Git.
4. Admission policy verifies the image signature before the workload can run.
5. External Secrets materializes runtime secrets from the vault.
6. Observability watches the platform from outside the cluster fate domain.

## Main Components

| Layer | Component class | Purpose |
|-------|-----------------|---------|
| Infrastructure | Proxmox plus Terraform | Declares and rebuilds the VM layer |
| Node OS | Talos Linux | Immutable Kubernetes nodes |
| Kubernetes network | Cilium | CNI, kube-proxy replacement, load balancing, network policy |
| GitOps | Argo CD | App-of-apps reconciliation and preview lifecycle |
| CI and registry | Gitea Actions plus OCI registry | Build, scan, sign, publish, and digest write-back |
| Admission | Kyverno plus cosign public key | Deny unsigned or wrongly signed images |
| Secrets | OpenBao plus External Secrets Operator | Keep values out of Git |
| Observability | Prometheus, Grafana, Alloy | SLOs, burn-rate alerts, and capacity visibility |
| Edge | Egress-only tunnel plus DNS automation | Public routes without inbound firewall exposure |
| Backups | Off-cluster snapshot receiver | Keep vault snapshots outside the cluster blast radius |

## Security Posture

- GitOps is the intended write path.
- Images are pinned by digest after CI.
- Admission checks signature identity, not just whether a signature exists.
- Secrets are referenced by policy and materialized at runtime.
- Platform namespaces are default-deny after audit.
- The public route is separated from the admin path.
- Backups are tested with restore drills, not just scheduled.

## Known Limits

- This is one physical hypervisor, so it is not true hardware HA.
- A single-host or disk failure can still take down the lab.
- The under-30-minute rebuild claim is not public-safe to claim yet.
- The public export is a narrative and evidence package, not the private runbook.

See `docs/diagrams/marduk-public.mmd` for a sanitized Mermaid diagram.
