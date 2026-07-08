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

12. Configure Kubernetes auth with private cluster trust material, then save the
    generated AppRole credential files to private custody.
13. Seed registry, backup, edge, preview, and signing secrets.
14. Revoke root and remove the init JSON:

   ```bash
   starter/scripts/openbao-first-install.sh revoke-root ./marduk.env
   ```

15. Verify post-root access:

   ```bash
   starter/scripts/openbao-first-install.sh verify-post-root ./marduk.env starter/security/openbao-approle-credentials/admin.json
   ```

16. Verify OpenBao still serves ESO.
17. Prove GitOps sync, signed admission, public route, observability, backup,
    and disaster-recovery checks.

## Passing Standard

The public repo can claim turnkey deploy only after this entire path passes from
a clean clone using documented inputs, with no private values copied from the
original MARDUK estate.
