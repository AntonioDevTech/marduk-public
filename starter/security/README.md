# Security Starter Notes

MARDUK's private implementation uses three core controls:

- Image signing plus admission verification.
- Vault-backed runtime secrets.
- Default-deny network policy.

Public starters should show the pattern, not real values.

## Signing

Use your own signing identity. Public-friendly options include keyless signing
with OIDC or a private signing key stored in a vault.

## Secrets

Do not commit secret values. Store them in your vault and sync only the runtime
Kubernetes Secret objects that workloads need.

See `openbao-first-install.md` for the first-install custody pattern. A rebuild
can restore a snapshot, but a brand-new user must first create the vault custody
set, policies, roles, AppRole credential custody, Kubernetes auth config, seed
secrets, revoke root, verify post-root access, and create the first backup.

## Network Policy

Roll default-deny out in audit-first order:

1. Observe real traffic.
2. Add explicit allows.
3. Enforce one namespace.
4. Verify.
5. Continue namespace by namespace.
