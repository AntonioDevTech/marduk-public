# LinkedIn Debut Copy

## Safe Short Post

I built MARDUK, a homelab Internal Developer Platform that recreates managed-cloud
control patterns at $0 software cost.

It is a simulated 3-node HA Kubernetes cluster on one hypervisor, so I am not
pretending it has multiple hardware failure domains. The point is the platform
control plane: immutable nodes, GitOps, signed-image-only admission, vault-backed
secrets, default-deny networking, SLO burn-rate alerts, off-cluster backups,
per-PR preview environments, and local AI code review.

The part I am proud of is not that it runs. The part I am proud of is that the
claims are evidenced: unsigned images are denied, drift snaps back to Git, alerts
actually fire, vault restore was drilled, and a node kill under load was tested.

Current honest rebuild status: the private platform has been rebuilt from
destroyed VMs to final verified green in under 10 minutes, with explicit human
custody and external-trust gates. The public repo is a sanitized starter, not a
full public Proxmox installer yet.

This public repo is a sanitized portfolio export. The operational repo stays
private because it contains real topology and recovery details.

## Safe Screenshot Rules

- Hide browser chrome.
- Hide account names and profile avatars.
- Hide real domains, IPs, hostnames, and internal URLs.
- Crop terminal prompts if they show usernames or machine names.
- Do not show token names, secret paths, fingerprints, custody locations, or
  firewall rule names.
- Prefer diagrams and dashboards with synthetic labels.

## Phrases To Avoid

- "Production HA"
- "Anyone can clone this and deploy the full platform" until the public
  clean-room proof exists
- "Zero risk"
- "Public repo contains the real infra"
- Any wording that implies multiple physical failure domains
