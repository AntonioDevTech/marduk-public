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
| Fresh first install with no existing vault snapshot | Helper mechanics, AppRole credential files, Kubernetes auth config submission, real ServiceAccount login, policy scoping, and post-root access proven against disposable OpenBao/kind resources, not full public cluster |

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
deploy-marduk-public.sh         Public starter harness and honest pause point
LICENSE                         MIT license for the sanitized export
docs/ARCHITECTURE-SANITIZED.md  Public architecture summary
docs/CONFIGURATION.md           Public config contract
docs/CLEAN-ROOM-PROOF.md        Proof ladder before turnkey claims
docs/EXTERNAL-GATES.md          Human-owned trust gates and proof pattern
docs/FAILOVER-DR-MATRIX.md      Public-safe recovery claim matrix
docs/GETTING-STARTED.md         How to run and adapt the starter
docs/BUILD-FROM-HERE.md         Build path from local app to platform
docs/DEPLOYABILITY.md           What is and is not turnkey today
docs/BLUEPRINT-CHECKLIST.md     Adaptation checklist
docs/EVIDENCE-SUMMARY.md        Claims and evidence types, without private data
docs/REBUILD-STATUS.md          Honest rebuild status
docs/LINKEDIN-DEBUT.md          Safe launch copy and screenshot rules
docs/OPENBAO-KUBERNETES-LOGIN-PROOF.md  Disposable K8s auth login proof
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
make test
make starter-doctor
./deploy-marduk-public.sh plan
./deploy-marduk-public.sh render-terraform starter/config/marduk.env.example -
./deploy-marduk-public.sh openbao-plan
./deploy-marduk-public.sh render-openbao starter/config/marduk.env.example /tmp/marduk-openbao-bootstrap
./deploy-marduk-public.sh openbao-first-install-dry-run
```

`make test` uses local Go when it is installed. If Go is missing but Docker is
available, it runs the same test inside the pinned Go container image.

If Docker, kind, and kubectl are available, this optional proof creates a
disposable kind cluster plus disposable OpenBao and proves a real Kubernetes
service account can log in through OpenBao Kubernetes auth while staying inside
its allowed policy:

```bash
make openbao-kubernetes-login-proof
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
make docker-build
make run-docker
```

## Build Your Own Version From Here

Start with:

```bash
cp -R starter my-marduk-ops
```

Then read:

- [`docs/CONFIGURATION.md`](docs/CONFIGURATION.md)
- [`docs/CLEAN-ROOM-PROOF.md`](docs/CLEAN-ROOM-PROOF.md)
- [`docs/EXTERNAL-GATES.md`](docs/EXTERNAL-GATES.md)
- [`docs/FAILOVER-DR-MATRIX.md`](docs/FAILOVER-DR-MATRIX.md)
- [`docs/GETTING-STARTED.md`](docs/GETTING-STARTED.md)
- [`docs/BUILD-FROM-HERE.md`](docs/BUILD-FROM-HERE.md)
- [`docs/BLUEPRINT-CHECKLIST.md`](docs/BLUEPRINT-CHECKLIST.md)

The starter includes:

- Proxmox/Terraform VM templates.
- Talos cluster and node patch examples.
- Argo CD app-of-apps bootstrap example.
- Kubernetes demo app manifests.
- Security notes plus OpenBao first-install policy, role, dry-run, bootstrap-apply,
  AppRole credential, Kubernetes-auth, root-revoke, and post-root verification
  helpers.

You still must supply your own private values: network plan, endpoints, DNS,
registry, vault, signing identity, and recovery process.

Today this repo helps you build your own version. It does not yet include the
sanitized equivalent of the private one-command deploy wrapper.

The public harness shows the current command surface:

```bash
./deploy-marduk-public.sh doctor
./deploy-marduk-public.sh verify-config ./marduk.env
./deploy-marduk-public.sh plan ./marduk.env
./deploy-marduk-public.sh render-terraform ./marduk.env starter/terraform/proxmox/terraform.tfvars
./deploy-marduk-public.sh openbao-plan ./marduk.env
./deploy-marduk-public.sh render-openbao ./marduk.env starter/security/openbao-bootstrap
./deploy-marduk-public.sh openbao-first-install-dry-run ./marduk.env
```

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
