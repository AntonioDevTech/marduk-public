# OpenBao First-Install Pattern

This is a public-safe outline. Do not paste real tokens, shares, or private keys
into a public repo.

## Why This Exists

A rebuild can restore a vault snapshot.

A first install has no snapshot yet. You must create the first custody set,
provision policies and roles, seed initial secrets, revoke root, and then create
the first backup.

## First-Install Order

Generate the non-secret policy and role skeleton first:

```bash
./deploy-marduk-public.sh openbao-plan ./marduk.env
./deploy-marduk-public.sh render-openbao ./marduk.env starter/security/openbao-bootstrap
./deploy-marduk-public.sh openbao-first-install-dry-run ./marduk.env
```

The generated bundle contains:

```text
policies/eso-ro.hcl
policies/raft-snapshot-ro.hcl
policies/ci-cosign-ro.hcl
policies/admin.hcl
payloads/kubernetes-role-eso.json
payloads/kubernetes-role-raft-snapshot.json
payloads/approle-admin.json
payloads/approle-ci-signing.json
```

1. Deploy OpenBao sealed and uninitialized.
2. Check the first-install helper before any live init:

   ```bash
   starter/scripts/openbao-first-install.sh preflight ./marduk.env
   starter/scripts/openbao-first-install.sh status ./marduk.env
   ```

3. Initialize with 3 Shamir shares and threshold 2:

   ```bash
   starter/scripts/openbao-first-install.sh init ./marduk.env --i-understand-this-prints-tier0-shares
   ```

   This command intentionally prints the unseal shares exactly once so a human
   can save them. It writes the root token only to the mode-600 init JSON path.
   Do not paste either value into chat, Git, tickets, screenshots, or public
   terminal transcripts.

4. Save all shares to your password manager plus paper/offline custody.
5. Unseal with 2 shares:

   ```bash
   starter/scripts/openbao-first-install.sh unseal ./marduk.env
   ```

6. Verify seal status:

   ```bash
   starter/scripts/openbao-first-install.sh status ./marduk.env
   ```

7. Enable a KV v2 mount for platform secrets.
8. Enable Kubernetes auth for External Secrets.
9. Enable AppRole auth for human/admin and CI claim tickets.
10. Create least-privilege policies:
   - External Secrets reads only runtime secret prefixes.
   - Snapshot job can only create raft snapshots.
   - CI signing role reads only the signing-key path.
   - Admin AppRole can manage the vault after root is revoked.
11. Seed initial secrets through request bodies or mode-600 files, never command
   arguments:
   - registry read token
   - backup ship key
   - DNS/public-edge token and tunnel credentials
   - preview-system read token
   - signing key and password
12. Verify External Secrets syncs every expected Kubernetes Secret.
13. Create and verify the first off-cluster raft snapshot.
14. Revoke root and shred the init file:

   ```bash
   starter/scripts/openbao-first-install.sh shred-init ./marduk.env
   ```

## Human Gates

These stay manual:

- saving unseal shares
- saving admin AppRole credentials
- creating external account tokens
- entering real secret values
- confirming the first backup exists outside the cluster

## Honest Deployability Note

Until this ceremony is implemented and tested in a sanitized operational package,
this public repo is a starter, not a turnkey installer. The generated bundle is
progress: it removes ambiguity from policy and role shape, but it does not
replace the live custody ceremony.
