# Starter Blueprint

This directory contains sanitized starter files for building a MARDUK-like
platform in your own lab.

It is not a turn-key installer. Real infrastructure requires real private
values, and those should live in your own private operational repo.

## Directory Map

```text
terraform/proxmox/  VM layer template for three Talos nodes
config/             Sourceable public config contract
scripts/            Config doctor and generated artifact helpers
talos/              Talos patch examples
kubernetes/         GitOps bootstrap and demo workload examples
security/           Policy and secret-management notes
```

## First Commands In A Private Copy

```bash
cp starter/config/marduk.env.example marduk.env
starter/scripts/doctor.sh ./marduk.env
starter/scripts/render-terraform-tfvars.sh ./marduk.env starter/terraform/proxmox/terraform.tfvars
./deploy-marduk-public.sh plan ./marduk.env
```

## Safety Rule

Do not put real secrets, private IPs, private hostnames, or recovery notes in a
public repo. Keep those in a private operational repo.
