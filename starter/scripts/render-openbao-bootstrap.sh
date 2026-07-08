#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT"

CONFIG="${1:-starter/config/marduk.env}"
OUTPUT="${2:-starter/security/openbao-bootstrap}"

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: config not found: $CONFIG" >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$CONFIG"

if [ "$OUTPUT" = "-" ]; then
  echo "ERROR: output directory is required for OpenBao bootstrap bundle" >&2
  exit 2
fi

mkdir -p "$OUTPUT/policies" "$OUTPUT/payloads"

cat > "$OUTPUT/policies/eso-ro.hcl" <<EOF
# External Secrets may read only runtime secret prefixes.
EOF

for prefix in $(printf '%s' "$OPENBAO_RUNTIME_SECRET_PREFIXES" | tr ',' ' '); do
  cat >> "$OUTPUT/policies/eso-ro.hcl" <<EOF
path "$OPENBAO_KV_MOUNT/data/$prefix/*" {
  capabilities = ["read"]
}

path "$OPENBAO_KV_MOUNT/metadata/$prefix/*" {
  capabilities = ["read", "list"]
}

EOF
done

cat > "$OUTPUT/policies/raft-snapshot-ro.hcl" <<'EOF'
# Snapshot jobs may read a raft snapshot and nothing else.
path "sys/storage/raft/snapshot" {
  capabilities = ["read"]
}
EOF

cat > "$OUTPUT/policies/ci-cosign-ro.hcl" <<EOF
# CI signing may read only the signing-key material path.
path "$OPENBAO_KV_MOUNT/data/$OPENBAO_CI_SIGNING_SECRET_PATH" {
  capabilities = ["read"]
}
EOF

cat > "$OUTPUT/policies/admin.hcl" <<'EOF'
# Human-owned break-glass/admin AppRole. Save the AppRole credentials privately.
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

cat > "$OUTPUT/payloads/kubernetes-role-eso.json" <<EOF
{
  "bound_service_account_names": ["$OPENBAO_EXTERNAL_SECRETS_SERVICE_ACCOUNT"],
  "bound_service_account_namespaces": ["$OPENBAO_EXTERNAL_SECRETS_NAMESPACE"],
  "policies": ["eso-ro"],
  "ttl": "1h"
}
EOF

cat > "$OUTPUT/payloads/kubernetes-role-raft-snapshot.json" <<EOF
{
  "bound_service_account_names": ["$OPENBAO_SNAPSHOT_SERVICE_ACCOUNT"],
  "bound_service_account_namespaces": ["$OPENBAO_SNAPSHOT_NAMESPACE"],
  "policies": ["raft-snapshot-ro"],
  "ttl": "15m"
}
EOF

cat > "$OUTPUT/payloads/approle-admin.json" <<'EOF'
{
  "token_policies": ["admin"],
  "token_ttl": "30m",
  "token_max_ttl": "30m",
  "secret_id_ttl": "0"
}
EOF

cat > "$OUTPUT/payloads/approle-ci-signing.json" <<EOF
{
  "token_policies": ["ci-cosign-ro"],
  "token_ttl": "5m",
  "token_max_ttl": "5m",
  "secret_id_ttl": "0"
}
EOF

cat > "$OUTPUT/README.md" <<EOF
# OpenBao First-Install Bootstrap Bundle

Generated from:

\`\`\`text
$CONFIG
\`\`\`

This bundle intentionally contains no secret values. It contains ACL policies and
role payloads that a private operator can apply after initializing and unsealing
a brand-new OpenBao.

## Files

\`\`\`text
policies/eso-ro.hcl
policies/raft-snapshot-ro.hcl
policies/ci-cosign-ro.hcl
policies/admin.hcl
payloads/kubernetes-role-eso.json
payloads/kubernetes-role-raft-snapshot.json
payloads/approle-admin.json
payloads/approle-ci-signing.json
\`\`\`

## Apply Order

1. Initialize OpenBao with 3 shares and threshold 2.
2. Save all shares to password manager plus paper/offline custody.
3. Unseal with any 2 shares.
4. Enable KV v2 at \`$OPENBAO_KV_MOUNT/\`.
5. Enable Kubernetes auth and AppRole auth.
6. Configure Kubernetes auth with a private token reviewer JWT and CA bundle.
7. Apply these policies.
8. Create these roles.
9. Seed real secret values through mode-600 files or stdin.
10. Verify every ExternalSecret and workload consumer.
11. Create and verify the first off-cluster raft snapshot.
12. Revoke root and shred temporary init material.

## Safety

Never commit real unseal shares, root tokens, AppRole secret IDs, registry
passwords, signing keys, DNS tokens, or backup private keys.
EOF

echo "wrote $OUTPUT"
