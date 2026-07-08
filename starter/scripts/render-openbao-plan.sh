#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT"

CONFIG="${1:-starter/config/marduk.env.example}"

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: config not found: $CONFIG" >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$CONFIG"

cat <<EOF
MARDUK public OpenBao first-install plan

Config file:
  $CONFIG

OpenBao shape from config:
  Address: $OPENBAO_ADDR
  KV v2 mount: $OPENBAO_KV_MOUNT/
  ESO service account: $OPENBAO_EXTERNAL_SECRETS_NAMESPACE/$OPENBAO_EXTERNAL_SECRETS_SERVICE_ACCOUNT
  Snapshot service account: $OPENBAO_SNAPSHOT_NAMESPACE/$OPENBAO_SNAPSHOT_SERVICE_ACCOUNT
  Admin AppRole: $OPENBAO_ADMIN_ROLE
  CI signing AppRole: $OPENBAO_CI_SIGNING_ROLE
  CI signing secret path: $OPENBAO_KV_MOUNT/data/$OPENBAO_CI_SIGNING_SECRET_PATH
  ESO runtime prefixes: $OPENBAO_RUNTIME_SECRET_PREFIXES

Generated local artifact:
  starter/scripts/render-openbao-bootstrap.sh "$CONFIG" starter/security/openbao-bootstrap
  starter/scripts/openbao-first-install.sh dry-run "$CONFIG"

Expected private first-install order:
  1. Deploy OpenBao sealed and uninitialized.
  2. Port-forward to OpenBao from a private terminal.
  3. Dry-run the first-install ceremony and review every human gate.
  4. Initialize 3 Shamir shares with threshold 2.
  5. Save all shares to password manager plus paper/offline custody.
  6. Unseal with any 2 shares.
  7. Apply the rendered non-secret bundle with apply-bootstrap.
  8. Configure Kubernetes auth with private cluster trust material.
  9. Create and privately save AppRole secret IDs.
  10. Enter real secret values through mode-600 files or stdin, never shell args.
  11. Verify External Secrets, signed-image admission, backup shipping, and public edge.
  12. Create the first off-cluster raft snapshot.
  13. Revoke root with revoke-root.

Manual gates that stay human-owned:
  - Save unseal shares.
  - Save admin AppRole credentials.
  - Provide registry, backup, public-edge, preview, and signing secrets.
  - Confirm the first backup exists outside the cluster fate domain.

Honest state:
  This public repo can render the non-secret OpenBao policy and role skeleton
  and prove helper mechanics against disposable OpenBao. It does not yet prove
  full first install against a fresh public cluster.
EOF
