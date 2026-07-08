# Blueprint Checklist

Use this checklist when adapting MARDUK to your own lab.

## Foundation

- [ ] Decide the hardware failure-domain story honestly.
- [ ] Pick a private network plan.
- [ ] Pick the Kubernetes node count and sizing.
- [ ] Pin Talos and Kubernetes versions.
- [ ] Create a private operational repository.

## Infrastructure

- [ ] Fill in Terraform variables.
- [ ] Run `terraform fmt`.
- [ ] Run `terraform plan`.
- [ ] Build the VM layer.
- [ ] Record evidence that nodes boot and are reachable.

## Kubernetes

- [ ] Generate fresh Talos secrets.
- [ ] Apply Talos machine configs.
- [ ] Bootstrap exactly one control-plane node.
- [ ] Install Cilium.
- [ ] Install Argo CD.
- [ ] Hand control to GitOps.

## Supply Chain

- [ ] Build the demo app in CI.
- [ ] Generate an SBOM.
- [ ] Scan for critical vulnerabilities.
- [ ] Sign the image.
- [ ] Deploy by immutable digest.
- [ ] Deny unsigned images at admission.

## Secrets

- [ ] Deploy a vault.
- [ ] Store real secret values only in the vault.
- [ ] Sync runtime secrets with External Secrets.
- [ ] Rotate any value that was ever displayed.
- [ ] Drill restore before you trust backups.

## Observability And Resilience

- [ ] Keep observability outside the cluster fate domain.
- [ ] Define a demo-app availability SLO.
- [ ] Test alert firing and resolution.
- [ ] Test pod kill.
- [ ] Test node kill.
- [ ] Record what failed and what you fixed.
