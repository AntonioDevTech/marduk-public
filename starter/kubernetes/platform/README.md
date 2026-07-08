# Platform Layer Checklist

Add platform Applications in GitOps sync waves so dependencies appear before the
things that need them.

## Suggested Waves

1. Gateway API CRDs.
2. Cilium.
3. Load-balancer address pool.
4. cert-manager.
5. Argo CD self-management.
6. OpenBao and External Secrets.
7. Admission policies.
8. Network policies.
9. Observability agents.
10. Workload apps.

## Verification Gates

Before moving to the next layer, prove the previous one:

- Nodes are Ready.
- Cilium agents are Ready.
- Argo CD can read the repo.
- External Secrets can read only the allowed OpenBao paths.
- Unsigned images are denied.
- Public route checks return the expected HTTP status.
- Observability sees the platform.

Public examples should use placeholders only. Keep private operational manifests
in your own private repo.
