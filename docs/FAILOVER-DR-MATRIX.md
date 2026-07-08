# Failover And Disaster-Recovery Matrix

This public repo summarizes the proof pattern without exposing private estate
details.

## Honest Boundary

MARDUK is a simulated 3-node HA cluster on one hypervisor. It can prove control
plane and workload recovery patterns, but one physical host is still one fate
domain.

## Proof Matrix

| Scenario | Private MARDUK Status | Public Starter Status | Passing Proof |
|---|---|---|---|
| Pod kill | Proven privately | User must reproduce | App stays available and replacement pod becomes Ready |
| Node power-off | Proven privately | User must reproduce | App remains reachable and SLO burn is visible |
| VM rebuild | Proven privately | User must reproduce | Declared VM state recreates nodes |
| Vault restore | Proven privately | First-install and restore path still needs public packaging | Restored vault unseals, ESO syncs, fresh snapshot ships |
| Git drift | Proven privately | User must reproduce | Hand edit reverts from GitOps |
| Unsigned image | Proven privately | User must reproduce | Admission denies unsigned workload |
| Backup target loss | Not a public claim | User must design | Restore path uses a separate backup copy |
| Hypervisor loss | Not protected | Not protected | Requires a second physical host or off-host DR design |

## Claim Rule

Only claim what you have tested in your own lab.

Example honest wording:

```text
The demo app survived a node power-off in my lab. This does not protect against
loss of the single physical hypervisor.
```

## Minimum Public Reproduction Set

Before saying your fork is production-like, test at least:

1. Pod kill.
2. Node power-off or hard VM stop.
3. Git drift correction.
4. Unsigned image denial.
5. Vault backup and restore.
6. Alert fire and resolve.
