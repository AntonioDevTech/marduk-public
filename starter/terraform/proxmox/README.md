# Proxmox Terraform Starter

This is a sanitized starter for a three-node Talos cluster on Proxmox.

It is a template, not a provider for someone else's lab. You must review the
inputs and adapt them to your Proxmox host, storage, bridge, VLAN, and IP plan.

## Files

```text
versions.tf              Provider pins
provider.tf              Provider configuration
variables.tf             Inputs with safe defaults and placeholders
nodes.tf                 Three VM template
terraform.tfvars.example Reference values only
```

## Usage

```bash
starter/scripts/render-terraform-tfvars.sh ./marduk.env starter/terraform/proxmox/terraform.tfvars
cd starter/terraform/proxmox
terraform init
terraform fmt
terraform plan
```

Do not commit your real `terraform.tfvars`.

## Review Before Apply

Check these before any real `terraform apply`:

- VM IDs do not collide with existing guests.
- Storage pool exists and has enough space.
- Network bridge and VLAN are correct.
- Talos image URL and checksum match what you intend to run.
- CPU and memory fit the host with headroom.
- Provider token has only the privileges it needs.

The private MARDUK estate proves this pattern can work. A public unchanged
Proxmox deployment still needs a separate clean-room proof.
