# External Gates

Some parts of MARDUK should not be hidden behind a script. They are trust
decisions, not just commands.

## Gate Matrix

| Gate | Human Owns | Automation Proves |
|---|---|---|
| Firewall | Rule creation, rule order, source and destination intent | Packet path reaches only the intended target |
| DNS and public edge | Account ownership, domain ownership, token scope | Public URL returns expected HTTP status |
| Vault custody | Unseal shares, root-of-trust material, recovery custody | Vault seal status and secret sync recover after unseal |
| Backup target | Host trust, SSH host key, receiver account | Snapshot lands outside the cluster and has expected size/hash |
| Observability | Contact points and routing ownership | Metrics, dashboards, and alert rules evaluate with live data |
| Signing identity | Private key custody and rotation | Admission accepts signed image and denies unsigned image |

## Public Starter Rule

The public starter may print what to verify, but it must not collect or store
secret values.

Good automation:

- checks that a URL returns HTTP 200
- checks that a Kubernetes resource is Ready
- checks that a snapshot file exists
- checks that a policy denies a test workload

Bad automation:

- asks for unseal shares in a config file
- stores account tokens in Git
- creates broad firewall rules without a packet proof
- marks a gate complete without testing it

## Evidence To Capture

For every external gate, record:

- what the human changed
- why the human owned it
- the exact proof command
- the success output
- the failure mode
- how to roll back or retry
