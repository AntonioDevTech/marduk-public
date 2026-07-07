# Rebuild Status

## Short Answer

MARDUK is ready to say: "I can rebuild this platform from destroyed VMs and bring
it back to green."

MARDUK is not ready to say: "I have proven the rebuild is under 30 minutes."

## What Has Been Demonstrated

- The VM layer can be destroyed and recreated.
- Talos machine configuration can rebuild the Kubernetes control plane.
- GitOps can rehydrate the platform from Git.
- OpenBao can be restored from a raft snapshot and unsealed by custody shares.
- External Secrets can resync all expected runtime secrets.
- Admission policy still denies unsigned images after the rebuild.
- The public demo route returned HTTP 200 after recovery.

## Latest Timing

| Run | Result | Timing | Honest interpretation |
|-----|--------|--------|-----------------------|
| First timed rebuild attempt | Rebuilt and green | 37m37s | Found and fixed a real Argo network-policy ordering bug |
| Clean rerun after that fix | Rebuilt and green | 33m45s | Found and fixed the staged default-deny anchor bug |

The next valid under-30 proof must start after the latest network-policy fix and
finish without mid-run code changes or break-glass recovery.

## Public Wording

Use this:

> The platform has been rebuilt from destroyed VMs and recovered to green. The
> latest timed rerun took 33m45s because it exposed a real rebuild-only
> network-policy staging bug, now fixed. The clean under-30-minute claim is still
> not proven.

Do not use this yet:

> MARDUK rebuilds in under 30 minutes.
