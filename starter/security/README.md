# Security Starter Notes

MARDUK's private implementation uses three core controls:

- Image signing plus admission verification.
- OpenBao-backed runtime secrets.
- Default-deny network policy.

The public starter shows the pattern without real values.

## Signing

Use your own signing identity. Public-friendly options include keyless signing
with OIDC or a private signing key stored in your vault.

The important rule is trust separation: do not sign unreviewed preview code with
the same identity that protects production platform images unless you have made
that decision on purpose.

## Secrets

Do not commit secret values. Store them in your vault and sync only the runtime
Kubernetes Secret objects that workloads need.

See `openbao-first-install.md` for the first-install custody pattern. A rebuild
can restore a snapshot, but a brand-new user must first create the vault custody
set, policies, roles, AppRole credential custody, Kubernetes auth config, seed
runtime secrets, revoke root, verify post-root access, and create the first
backup.

## Network Policy

Roll default-deny out in audit-first order:

1. Observe real traffic.
2. Add explicit allows.
3. Enforce one namespace.
4. Verify.
5. Continue namespace by namespace.

## Human Gates

The public starter does not automate custody, firewall ownership, DNS ownership,
Cloudflare account setup, or password-manager actions. Those are human trust
gates and should be documented in your private runbook.
