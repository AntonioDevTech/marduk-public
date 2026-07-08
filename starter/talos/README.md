# Talos Starter

These files show the Talos patch shape used by MARDUK without private values.

## First Rule

Generate your own Talos secrets. Never reuse secrets from another lab.

```bash
talosctl gen secrets --output-file secrets.yaml
```

Then generate your cluster config using your own endpoint and patches.

## What To Decide

- Cluster endpoint and VIP.
- Node IPs and hostnames.
- Machine install disk.
- Image factory schematic and extensions.
- Registry trust and pull path.
- Kubernetes version compatibility with your platform layer.

Keep generated Talos secrets in private custody. Do not publish them in this
starter or in screenshots.
