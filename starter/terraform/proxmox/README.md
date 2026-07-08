# Proxmox Terraform Starter

This is a sanitized starter for a three-node Talos cluster on Proxmox.

## Files

```text
versions.tf              Provider pins
provider.tf              Provider configuration
variables.tf             Inputs with safe defaults/placeholders
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
