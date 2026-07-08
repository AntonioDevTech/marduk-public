# Starter Blueprint

This directory contains sanitized starter files for building a MARDUK-like
platform in your own lab.

It is not a turn-key installer. Real infrastructure requires real private
values, and those should live in your own private operational repo.

## Directory Map

```text
terraform/proxmox/  VM layer template for three Talos nodes
talos/              Talos patch examples
kubernetes/         GitOps bootstrap and demo workload examples
security/           Policy and secret-management notes
```

## Safety Rule

Do not put real secrets, private IPs, private hostnames, or recovery notes in a
public repo. Keep those in a private operational repo.
