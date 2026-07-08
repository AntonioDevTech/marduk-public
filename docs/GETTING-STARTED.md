# Getting Started

This repo is a safe starter version of MARDUK. It gives you the shape of the
platform without private estate details.

## Quick Local Demo

Check prerequisites first:

```bash
make doctor
```

That checks for Go or Docker. Local Go is enough for `make test` and `make run`.
If Go is missing but Docker is available, `make test` runs inside the pinned Go
container image. Docker is also required for `make docker-build` and
`make run-docker`.

Run the test:

```bash
make test
make starter-doctor
```

Run the demo service:

```bash
make run
```

Or build it as a container:

```bash
make docker-build
make run-docker
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
starter/config/               Public config example
starter/scripts/              Public doctor checks
starter/talos/                Talos cluster and node patch examples
starter/kubernetes/           GitOps bootstrap and demo app examples
starter/security/             Admission, secret, and policy notes
```

To adapt it:

1. Copy `starter/` into your own private operational repo.
2. Replace every `example.*` value with your own values.
3. Copy `starter/config/marduk.env.example` to `marduk.env`.
4. Run `starter/scripts/doctor.sh ./marduk.env`.
5. Render the concrete starter Terraform inputs:

   ```bash
   starter/scripts/render-terraform-tfvars.sh ./marduk.env starter/terraform/proxmox/terraform.tfvars
   ```

6. Review the generated deploy plan:

   ```bash
   ./deploy-marduk-public.sh plan ./marduk.env
   ```

7. Render the OpenBao first-install policy and role bundle:

   ```bash
   ./deploy-marduk-public.sh openbao-plan ./marduk.env
   ./deploy-marduk-public.sh render-openbao ./marduk.env starter/security/openbao-bootstrap
   ./deploy-marduk-public.sh openbao-first-install-dry-run ./marduk.env
   ```

8. Read `starter/security/openbao-first-install.md` before running any live
   OpenBao init. The live init command intentionally requires an explicit
   confirmation flag because it prints tier-0 unseal shares for you to save.
   The helper can also apply the generated non-secret bundle, write AppRole
   credential files, revoke root, and verify post-root access. You still own
   Kubernetes auth config, private custody for those credential files, and real
   secret values.
9. Generate your own Talos secrets. Never reuse anyone else's.
10. Create your own registry, signing key, vault, and DNS records.
11. Run a secret scanner and a private-value grep before publishing anything.

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
`starter/` files and OpenBao dry-run helper as a blueprint until the public
operational package is added and proven from a clean clone.
