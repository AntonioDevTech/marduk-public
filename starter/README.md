# Starter Blueprint

This directory is the public-safe starting point for building a MARDUK-like
platform in your own private repo.

It is not a full Proxmox installer by itself. Real infrastructure needs real
private values, and those values belong in your private operational repo.

## ICM Shape

```text
config/             Sourceable public config contract
terraform/proxmox/  Three-node Proxmox/Talos VM template
talos/              Talos patch examples
kubernetes/         GitOps bootstrap and demo workload examples
security/           OpenBao, signing, policy, and network notes
scripts/            Doctors, renderers, and disposable proof helpers
```

## First Commands In A Private Copy

```bash
cp starter/config/marduk.env.example marduk.env
starter/scripts/doctor.sh ./marduk.env
starter/scripts/render-terraform-tfvars.sh ./marduk.env starter/terraform/proxmox/terraform.tfvars
./deploy-marduk-public.sh plan ./marduk.env
```

## What You Add

- Your Proxmox endpoint and storage choices.
- Your VLAN or subnet plan.
- Your Talos secrets and cluster endpoint.
- Your Git repo, registry, DNS, and edge provider.
- Your OpenBao custody and backup destination.
- Your signing identity and admission policy trust root.

## Safety Rule

Do not put real secrets, private IPs, private hostnames, custody notes, or
recovery values in a public repo. Keep those in a private operational repo.
