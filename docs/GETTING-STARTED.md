# Getting Started

This repo is a safe starter version of MARDUK. It gives you the shape of the
platform without private estate details.

## Quick Local Demo

Check prerequisites first:

```bash
make doctor
```

That checks for Go and warns if Docker is missing. Go is required for
`make test` and `make run`; Docker is required for `make docker-build`.

Run the demo service:

```bash
make run
```

Or build it as a container:

```bash
make docker-build
docker run --rm -p 8080:8080 marduk-hello:local
```

Then check:

```text
http://127.0.0.1:8080/
http://127.0.0.1:8080/healthz
```

## Use The Platform Starter

The `starter/` directory is the reusable blueprint:

```text
starter/terraform/proxmox/    Three-node Proxmox/Talos VM template
starter/talos/                Talos cluster and node patch examples
starter/kubernetes/           GitOps bootstrap and demo app examples
starter/security/             Admission, secret, and policy notes
```

To adapt it:

1. Copy `starter/` into your own private operational repo.
2. Replace every `example.*` value with your own values.
3. Generate your own Talos secrets. Never reuse anyone else's.
4. Create your own registry, signing key, vault, and DNS records.
5. Run a secret scanner and a private-value grep before publishing anything.

## What You Should Not Copy Blindly

The templates are intentionally conservative. You must still choose:

- Your real network layout.
- Your Proxmox storage and bridge names.
- Your Talos and Kubernetes versions.
- Your Git host and registry.
- Your secret manager configuration.
- Your DNS and public edge model.

MARDUK is a pattern, not a magic script.

## Current Deployability Status

The private MARDUK estate has a proven wrapper that rebuilds from destroyed VMs
to final PASS with explicit human gates.

This public repo does not yet contain that full sanitized wrapper. Treat the
`starter/` files as a blueprint until the public operational package is added
and proven from a clean clone.
