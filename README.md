# MARDUK

MARDUK is a sanitized public portfolio export of a private Internal Developer
Platform lab.

It shows how managed-cloud platform controls can be reproduced on a homelab
budget: immutable Kubernetes nodes, GitOps, signed-image-only admission,
vault-backed secrets, default-deny networking, SLO burn-rate alerts,
off-cluster backups, per-PR preview environments, and advisory local-AI code
review.

**Honesty clause:** MARDUK is a simulated 3-node HA cluster on one hypervisor.
It proves platform control patterns, not multi-hardware failure-domain
availability. One physical box is still one fate domain.

## Why This Exists

Most homelab Kubernetes projects prove that containers can run. MARDUK tries to
prove something harder:

- Can the platform rebuild from declared state?
- Can Git be the only intended write path?
- Can unsigned images be denied before they run?
- Can secrets stay out of Git?
- Can alerts, backups, and failure drills be tested instead of assumed?
- Can preview environments and AI review exist without paid cloud services?

The private operational repo contains the full implementation and evidence. This
public repo is the safe version: a runnable demo app, reusable starter templates,
and enough architecture to build your own version without exposing mine.

## What Is Built

| Area | What MARDUK demonstrates |
|------|--------------------------|
| Infrastructure | VM layer declared with Terraform and rebuilt from code |
| Node OS | Immutable Talos Linux nodes with pinned versions |
| Kubernetes networking | Cilium for CNI, kube-proxy replacement, load balancing, and policy |
| GitOps | Argo CD app-of-apps as the platform control loop |
| Supply chain | CI builds, SBOMs, CVE gates, signing, attestations, and digest write-back |
| Admission control | Kyverno verifies image signatures and denies unsigned platform images |
| Secrets | OpenBao plus External Secrets keeps values out of Git |
| Network policy | Namespaces move through audit into enforced default-deny |
| Observability | Out-of-band Prometheus/Grafana with SLO and capacity alerts |
| Backups | Vault snapshots are shipped outside the cluster blast radius |
| Preview environments | Labelled pull requests create isolated public previews |
| AI review | A local model posts advisory security review feedback |

## Current Proof Status

| Claim | Status |
|-------|--------|
| Platform rebuilds from destroyed VMs | Proven privately |
| Platform returns to green after vault restore | Proven privately |
| Unsigned image admission is denied | Proven privately |
| Git drift is reverted by GitOps | Proven privately |
| SLO and disk alerts fire for real | Proven privately |
| Node kill under load preserves the demo app | Proven privately |
| Clean private rebuild under 30 minutes | Proven privately |
| Random-user public clone deploys the full platform | Not proven yet |
| Fresh first install with no existing vault snapshot | Not packaged yet |

Latest honest rebuild wording:

> The private MARDUK estate has been rebuilt from destroyed VMs to final verified
> green in under 10 minutes, with explicit human custody and external-trust gates.
> This public repo is currently a sanitized starter, not yet a turnkey installer.

## Architecture At A Glance

```mermaid
flowchart TB
  dev["Developer"] --> repo["Git repo"]
  repo --> ci["CI: build, SBOM, scan, sign"]
  ci --> registry["OCI registry"]
  ci --> repo
  repo --> argo["GitOps reconciler"]
  argo --> admit["Admission policy"]
  admit --> app["Signed demo app"]
  vault["Vault"] --> eso["External Secrets"]
  eso --> app
  app --> obs["Out-of-band observability"]
  vault --> backup["Off-cluster backup"]
```

For the fuller sanitized diagram, see
[`docs/diagrams/marduk-public.mmd`](docs/diagrams/marduk-public.mmd).

## What Is In This Public Repo

```text
apps/hello/                     Tiny demo service used as a supply-chain carrier
LICENSE                         MIT license for the sanitized export
docs/ARCHITECTURE-SANITIZED.md  Public architecture summary
docs/GETTING-STARTED.md         How to run and adapt the starter
docs/BUILD-FROM-HERE.md         Build path from local app to platform
docs/DEPLOYABILITY.md           What is and is not turnkey today
docs/BLUEPRINT-CHECKLIST.md     Adaptation checklist
docs/EVIDENCE-SUMMARY.md        Claims and evidence types, without private data
docs/REBUILD-STATUS.md          Honest rebuild status
docs/LINKEDIN-DEBUT.md          Safe launch copy and screenshot rules
docs/PUBLIC-SAFETY.md           What was removed and why
docs/SCAN-REPORT.md             Public export scan result
docs/diagrams/marduk-public.mmd Sanitized Mermaid architecture
starter/                        Sanitized Terraform, Talos, Kubernetes, and security starters
.github/workflows/ci.yml        Public CI for the demo app and safety check
Makefile                        Local build/test helpers
compose.yaml                    Local container demo
```

The demo app is intentionally small. Its job is to travel through the platform:
source, build, scan, sign, push, digest write-back, GitOps deploy, admission
verify, and health probe.

## Run The Demo App Locally

First check local prerequisites:

```bash
make doctor
```

```bash
cd apps/hello
go run .
```

Then open:

```text
http://127.0.0.1:8080/
http://127.0.0.1:8080/healthz
```

Or build the container:

```bash
cd apps/hello
docker build -t marduk-hello:local .
docker run --rm -p 8080:8080 marduk-hello:local
```

## Build Your Own Version From Here

Start with:

```bash
cp -R starter my-marduk-ops
```

Then read:

- [`docs/GETTING-STARTED.md`](docs/GETTING-STARTED.md)
- [`docs/BUILD-FROM-HERE.md`](docs/BUILD-FROM-HERE.md)
- [`docs/BLUEPRINT-CHECKLIST.md`](docs/BLUEPRINT-CHECKLIST.md)

The starter includes:

- Proxmox/Terraform VM templates.
- Talos cluster and node patch examples.
- Argo CD app-of-apps bootstrap example.
- Kubernetes demo app manifests.
- Security notes for signing, vault-backed secrets, and network policy.

You still must supply your own private values: network plan, endpoints, DNS,
registry, vault, signing identity, and recovery process.

Today this repo helps you build your own version. It does not yet include the
sanitized equivalent of the private one-command deploy wrapper.

## What Is Not Included

This public export deliberately excludes:

- Private Git history.
- Terraform state and operational infrastructure manifests.
- Kubernetes manifests from the private estate.
- The private deploy wrapper and recovery runbooks.
- Real domains, hostnames, usernames, IP ranges, service ports, and device names.
- Credential identifiers, token names, key fingerprints, secret paths, and
  custody locations.
- Screenshots, terminal captures, and browser chrome.
- Session logs, troubleshooting logs, incident logs, and recovery runbooks.

The operational repo should stay private. Publish this sanitized export instead.

## Public Release Safety

The export was checked with:

- gitleaks 8.28.0 on the tracked export.
- gitleaks 8.28.0 on the standalone one-commit public repo.
- Grep denylist for real estate domains, private IPs, hostnames, names,
  credential metadata, and key fingerprints.
- Private-key and common token-prefix grep.
- Markdown em dash check.

Result: no leaks found in the sanitized export.

See [`docs/SCAN-REPORT.md`](docs/SCAN-REPORT.md) for the recorded scan result.
