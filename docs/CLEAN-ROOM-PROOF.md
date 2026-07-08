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

5. Build the VM substrate with Terraform.
6. Bootstrap Talos and Kubernetes with fresh Talos secrets.
7. Seed Cilium and Argo CD.
8. Run the OpenBao first-install ceremony.
9. Seed registry, backup, edge, preview, and signing secrets.
10. Prove GitOps sync, signed admission, public route, observability, backup,
    and disaster-recovery checks.

## Passing Standard

The public repo can claim turnkey deploy only after this entire path passes from
a clean clone using documented inputs, with no private values copied from the
original MARDUK estate.
