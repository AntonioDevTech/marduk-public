# Clean-Room Proof Plan

This is the proof required before the public repo can honestly say
"clone and deploy."

## Starting State

- Fresh clone of the public repo.
- No private MARDUK operational repo.
- A Proxmox host or lab cluster owned by the tester.
- User-created private `marduk.env`.
- User-created custody material.

## Proof Order

1. Run public local checks:

   ```bash
   make doctor
   make test
   make docker-build
   ```

2. Validate the public example config:

   ```bash
   make starter-doctor
   ```

3. Copy `starter/` into a private operational repo.
4. Create a real `marduk.env` and run:

   ```bash
   starter/scripts/doctor.sh ./marduk.env
   ```

5. Render and review the generated deployment plan:

   ```bash
   ./deploy-marduk-public.sh plan ./marduk.env
   ```

6. Render the Terraform starter variables:

   ```bash
   starter/scripts/render-terraform-tfvars.sh ./marduk.env starter/terraform/proxmox/terraform.tfvars
   ```

7. Render the OpenBao first-install bundle:

   ```bash
   ./deploy-marduk-public.sh openbao-plan ./marduk.env
   ./deploy-marduk-public.sh render-openbao ./marduk.env starter/security/openbao-bootstrap
   ./deploy-marduk-public.sh openbao-first-install-dry-run ./marduk.env
   ```

8. Build the VM substrate with Terraform.
9. Bootstrap Talos and Kubernetes with fresh Talos secrets.
10. Seed Cilium and Argo CD.
11. Run the live OpenBao first-install ceremony in a private terminal:

   ```bash
   starter/scripts/openbao-first-install.sh preflight ./marduk.env
   starter/scripts/openbao-first-install.sh status ./marduk.env
   starter/scripts/openbao-first-install.sh init ./marduk.env --i-understand-this-prints-tier0-shares
   starter/scripts/openbao-first-install.sh unseal ./marduk.env
   starter/scripts/openbao-first-install.sh apply-bootstrap ./marduk.env starter/security/openbao-bootstrap
   starter/scripts/openbao-first-install.sh write-approle-credentials ./marduk.env starter/security/openbao-approle-credentials
   ```

   Save all printed unseal shares to private custody before continuing. Do not
   paste them into chat, Git, issues, screenshots, or public logs.

12. Save the generated AppRole credential files to private custody, then
    configure Kubernetes auth with private cluster trust material:

   ```bash
   starter/scripts/openbao-first-install.sh configure-kubernetes-auth ./marduk.env starter/security/openbao-kubernetes-auth.json
   ```

13. Optional local proof before touching a real cluster: with Docker, kind, and
    kubectl installed, prove the public helper's Kubernetes auth shape against
    disposable resources:

   ```bash
   make openbao-kubernetes-login-proof
   ```

14. Optional local proof before touching real secrets: with Docker, kind,
    kubectl, and Helm installed, prove External Secrets can sync an OpenBao value
    into a Kubernetes Secret:

   ```bash
   make openbao-eso-sync-proof
   ```

15. Optional local proof before touching real secrets: prove the public
    `seed-runtime-secrets` helper can write public-safe registry and backup
    values through a mode-600 seed file and then sync both through External
    Secrets:

   ```bash
   make openbao-secret-seeding-proof
   ```

16. Seed registry, backup, edge, preview, and signing secrets privately:

   ```bash
   starter/scripts/openbao-first-install.sh seed-runtime-secrets ./marduk.env starter/security/openbao-runtime-secrets.json
   ```

   The seed file must be mode 600. It must use only prefixes allowed by
   `OPENBAO_RUNTIME_SECRET_PREFIXES`. Do not print its values.

17. Verify the seeded secrets are consumed by their target controllers.

18. Optional local proof before touching a real backup target: prove a
    disposable raft snapshot can be shipped to a forced-command SSH receiver:

   ```bash
   make openbao-backup-proof
   ```

19. Prove your real backup target and snapshot shipping path with your private
    host keys, user, forced command, and firewall rule.

20. Optional local proof before touching real DNS or Cloudflare: prove the demo
    app routes through a disposable edge proxy by hostname:

   ```bash
   make public-edge-proof
   ```

21. Prove your real DNS, public-edge account, tunnel, token scope, and public
    route with your private domain.

22. Revoke root and remove the init JSON:

   ```bash
   starter/scripts/openbao-first-install.sh revoke-root ./marduk.env
   ```

23. Verify post-root access:

   ```bash
   starter/scripts/openbao-first-install.sh verify-post-root ./marduk.env starter/security/openbao-approle-credentials/admin.json
   ```

24. Verify OpenBao still serves ESO.
25. Prove GitOps sync, signed admission, public route, observability, backup,
    and disaster-recovery checks.

## Passing Standard

The public repo can claim turnkey deploy only after this entire path passes from
a clean clone using documented inputs, with no private values copied from the
original MARDUK estate.
