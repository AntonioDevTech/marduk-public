# Talos Starter

These files show the Talos patch shape used by MARDUK without private values.

Generate your own secrets:

```bash
talosctl gen secrets --output-file secrets.yaml
```

Then generate your own cluster config using your private endpoint and patches.
Do not reuse secrets from another lab.

