# Build From Here

This public repo is designed to be useful in two ways:

1. Run and inspect the demo app locally.
2. Use `starter/` as a sanitized platform blueprint for your own environment.

## Local App Build

```bash
make test
make docker-build
docker run --rm -p 8080:8080 marduk-hello:local
```

## Platform Build Path

The platform path is intentionally a starter, because real infrastructure values
must be private.

Recommended order:

1. Prepare a private operational repo from `starter/`.
2. Fill in Terraform variables for your Proxmox endpoint, storage, bridge, and
   node IP plan.
3. Run Terraform to create the VMs.
4. Generate Talos machine configs from your own secrets.
5. Bootstrap Kubernetes.
6. Install Cilium and Argo CD.
7. Point Argo CD at your private operational repo.
8. Add registry, signing, vault, admission policy, observability, and backups.
9. Write evidence for each claim before you make it publicly.

## Why The Public Repo Is Not The Operational Repo

The operational repo for a real platform contains sensitive topology and recovery
details. Publishing that directly would expose too much. This repo keeps the
architecture and starter code while removing the private values.

