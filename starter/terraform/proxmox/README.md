# Proxmox Terraform Starter

This is a sanitized starter for a three-node Talos cluster on Proxmox.

## Files

```text
versions.tf              Provider pins
provider.tf              Provider configuration
variables.tf             Inputs with safe defaults/placeholders
nodes.tf                 Three VM template
terraform.tfvars.example Copy to terraform.tfvars in your private repo
```

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt
terraform plan
```

Do not commit your real `terraform.tfvars`.

