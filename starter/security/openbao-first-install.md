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

7. Apply the non-secret bootstrap bundle:

   ```bash
   starter/scripts/openbao-first-install.sh apply-bootstrap ./marduk.env starter/security/openbao-bootstrap
   ```

   This enables the KV mount, enables Kubernetes and AppRole auth, applies the
   generated policies, and creates the generated roles. It does not configure
   Kubernetes auth with private cluster credentials, does not create AppRole
   secret IDs, and does not seed real secret values.

8. Write AppRole credential files and save them privately:

   ```bash
   starter/scripts/openbao-first-install.sh write-approle-credentials ./marduk.env starter/security/openbao-approle-credentials
   ```

   The output directory is ignored by Git. The command prints file paths and
   status only, not role IDs or secret IDs. Save those files to private custody
   before root is revoked.

9. Configure Kubernetes auth with a private token reviewer JWT, Kubernetes host,
   and CA bundle from your cluster.
10. Verify the least-privilege policy shape:
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
14. Revoke root and remove the init file:

   ```bash
   starter/scripts/openbao-first-install.sh revoke-root ./marduk.env
   ```

15. Verify post-root admin access with a throwaway secret round trip:

   ```bash
   starter/scripts/openbao-first-install.sh verify-post-root ./marduk.env starter/security/openbao-approle-credentials/admin.json
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
this public repo is a starter, not a turnkey installer. The generated bundle and
helper remove ambiguity from policy, role, AppRole credential, and post-root
access mechanics, but they do not replace the live custody ceremony.
