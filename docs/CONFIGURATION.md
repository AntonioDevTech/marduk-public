# Configuration Contract

The public repo cannot ship real estate values. A deployable operational repo
needs a private config file with your own topology.

Start here:

```bash
cp starter/config/marduk.env.example marduk.env
```

Then replace every placeholder.

## Validate The Shape

The public example should validate with placeholders allowed:

```bash
starter/scripts/doctor.sh starter/config/marduk.env.example --allow-placeholders
```

Your private config should validate without placeholders:

```bash
starter/scripts/doctor.sh ./marduk.env
```

Render the Terraform starter variables from the same config:

```bash
starter/scripts/render-terraform-tfvars.sh ./marduk.env starter/terraform/proxmox/terraform.tfvars
```

`terraform.tfvars` contains real topology once generated. Keep it in your
private operational repo and do not publish it.

Render the OpenBao first-install plan and non-secret bootstrap bundle from the
same config:

```bash
./deploy-marduk-public.sh openbao-plan ./marduk.env
./deploy-marduk-public.sh render-openbao ./marduk.env starter/security/openbao-bootstrap
./deploy-marduk-public.sh openbao-first-install-dry-run ./marduk.env
```

The OpenBao bundle contains ACL policies and role payloads only. It must not
contain unseal shares, root tokens, AppRole secret IDs, or secret values.

The first-install dry run prints the intended ceremony order and does not
contact OpenBao. The live helper refuses to initialize a vault unless a human
passes the explicit confirmation flag documented in
`starter/security/openbao-first-install.md`.

## What Belongs In The Config

- Proxmox endpoint, node, storage, and bridge names.
- Proxmox TLS mode and Talos image file ID.
- VM IDs and node IPs.
- Kubernetes VIP, CIDR prefix, gateway, and DNS values.
- GitOps repo URL.
- Registry hostname.
- Public domain.
- Backup target host.
- Observability endpoint.
- OpenBao address, KV mount, service-account names, role names, runtime secret
  prefixes, and signing-key path names.

## What Does Not Belong In The Config

Never put these values in the public repo:

- Proxmox API token values.
- Talos secrets.
- OpenBao unseal shares.
- Root tokens.
- AppRole secret IDs.
- Registry passwords.
- Cloudflare tokens.
- Signing keys or passwords.

Those belong in your private custody process and secret manager.
