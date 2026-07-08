# Rebuild Status

## Short Answer

MARDUK is ready to say: "I can rebuild the private platform from destroyed VMs
and bring it back to green."

MARDUK is also ready to say: "The private wrapper has rebuilt the platform in
under 10 minutes with explicit human custody gates."

MARDUK is not ready to say: "A random Proxmox user can clone this public repo and
deploy the whole platform unchanged."

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
| Codex-driven Phase 11 wrapper proof | Rebuilt and green | 9m38s from safe prep start | Proved the fixed private wrapper end to end |
| Antonio manual Phase 11 wrapper proof | Rebuilt and green | 8m50s from safe prep start | Proved the operator path manually |

The private-estate under-30 proof is now satisfied by the Phase 11 wrapper
proofs. The public deployability proof is separate and still pending.

## Public Wording

Use this:

> The private MARDUK estate now rebuilds from destroyed VMs to verified green in
> under 10 minutes, with explicit human custody and external-trust gates.

Do not use this yet:

> Anyone can clone this public repo and deploy the full platform unchanged.
