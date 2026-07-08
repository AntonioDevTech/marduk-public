# Kubernetes Starter

This directory shows the GitOps shape used by MARDUK without private manifests
or private values.

## Map

```text
bootstrap/root-app.yaml  Apply once after Argo CD exists
apps/hello/              Demo app manifests
platform/README.md       Platform layer checklist
```

## Intended Flow

```text
Terraform creates VMs
Talos creates Kubernetes
operator installs Argo CD once
root-app.yaml points Argo at your private operational repo
Argo reconciles platform and apps from Git
```

Replace the example repo URL with your own private operational repo. Do not point
the public starter at a repo that contains real secrets or private recovery
notes.
