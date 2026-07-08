#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT"

IMAGE="${OPENBAO_IMAGE:-openbao/openbao:2.5.5}"
ESO_CHART_VERSION="${ESO_CHART_VERSION:-2.7.0}"
STAMP=$(date +%s)
CLUSTER="marduk-bao-eso-$STAMP-$$"
BAO_CONTAINER="marduk-bao-eso-bao-$STAMP-$$"
TMPDIR=$(mktemp -d "${TMPDIR:-/tmp}/marduk-bao-eso-proof.XXXXXX")
OPENBAO_ADDR=""

die() {
  echo "ERROR: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

cleanup_tmpdir() {
  if [ -d "$TMPDIR" ]; then
    docker run --rm -v "$TMPDIR:/proof" "$IMAGE" sh -c \
      'rm -rf /proof/* /proof/.[!.]* /proof/..?*' >/dev/null 2>&1 || true
    rmdir "$TMPDIR" >/dev/null 2>&1 || true
  fi
}

cleanup() {
  set +e
  docker rm -f "$BAO_CONTAINER" >/dev/null 2>&1 || true
  kind delete cluster --name "$CLUSTER" >/dev/null 2>&1 || true
  cleanup_tmpdir
}

trap cleanup EXIT INT TERM

json_get() {
  python3 - "$1" "$2" <<'PY'
import json
import sys

path, key = sys.argv[1:3]
d = json.load(open(path))
value = d
for part in key.split("."):
    if isinstance(value, list):
        value = value[int(part)]
    else:
        value = value[part]
print(value)
PY
}

bao_curl() {
  method="$1"
  token="$2"
  path="$3"
  data_file="${4:-}"
  url="$OPENBAO_ADDR/v1/$path"
  if [ -n "$data_file" ]; then
    curl -fsS -X "$method" -H "X-Vault-Token: $token" --data @"$data_file" "$url"
  else
    curl -fsS -X "$method" -H "X-Vault-Token: $token" "$url"
  fi
}

seal_summary() {
  curl -fsS "$OPENBAO_ADDR/v1/sys/seal-status" \
    | python3 -c 'import json,sys; d=json.load(sys.stdin); print("initialized=%s sealed=%s threshold=%s shares=%s progress=%s" % (d.get("initialized"), d.get("sealed"), d.get("t"), d.get("n"), d.get("progress")))'
}

wait_for_openbao() {
  i=0
  while [ "$i" -lt 60 ]; do
    if curl -fsS "$OPENBAO_ADDR/v1/sys/seal-status" >/dev/null 2>&1; then
      return 0
    fi
    i=$((i + 1))
    sleep 1
  done
  docker logs "$BAO_CONTAINER" >&2 || true
  die "OpenBao did not become reachable"
}

wait_for_kind() {
  i=0
  while [ "$i" -lt 60 ]; do
    if kubectl --context "kind-$CLUSTER" get --raw=/readyz >/dev/null 2>&1; then
      return 0
    fi
    i=$((i + 1))
    sleep 2
  done
  die "kind Kubernetes API did not become ready"
}

write_env_file() {
  cat > "$TMPDIR/marduk.env" <<EOF
MARDUK_CLUSTER_NAME=marduk-kind-eso-proof
PROXMOX_ENDPOINT=https://proxmox.example.invalid:8006/api2/json
PROXMOX_INSECURE_TLS=false
PROXMOX_NODE=example-node
PROXMOX_STORAGE=example-storage
PROXMOX_BRIDGE=vmbr0
MARDUK_VLAN_ID=40
MARDUK_GATEWAY=192.0.2.1
MARDUK_DNS=192.0.2.53
MARDUK_CIDR_PREFIX=24
TALOS_IMAGE_FILE_ID=local:import/talos-example.qcow2
MARDUK_NODE1_NAME=marduk-01
MARDUK_NODE1_IP=192.0.2.11
MARDUK_NODE1_VMID=1001
MARDUK_NODE2_NAME=marduk-02
MARDUK_NODE2_IP=192.0.2.12
MARDUK_NODE2_VMID=1002
MARDUK_NODE3_NAME=marduk-03
MARDUK_NODE3_IP=192.0.2.13
MARDUK_NODE3_VMID=1003
MARDUK_KUBE_VIP=192.0.2.10
GITOPS_REPO_URL=git@example.invalid:owner/private-marduk-ops.git
REGISTRY_HOSTNAME=registry.example.invalid
PUBLIC_DOMAIN=example.invalid
BACKUP_TARGET_HOST=backup.example.invalid
OBSERVABILITY_ENDPOINT=https://grafana.example.invalid
OPENBAO_ADDR=$OPENBAO_ADDR
OPENBAO_INIT_JSON=$TMPDIR/init.json
OPENBAO_KV_MOUNT=marduk
OPENBAO_EXTERNAL_SECRETS_NAMESPACE=external-secrets
OPENBAO_EXTERNAL_SECRETS_SERVICE_ACCOUNT=external-secrets
OPENBAO_SNAPSHOT_NAMESPACE=openbao
OPENBAO_SNAPSHOT_SERVICE_ACCOUNT=openbao-snapshot
OPENBAO_ADMIN_ROLE=admin
OPENBAO_CI_SIGNING_ROLE=ci-cosign
OPENBAO_CI_SIGNING_SECRET_PATH=ci/cosign
OPENBAO_RUNTIME_SECRET_PREFIXES=registry,backup,edge
EOF
  chmod 600 "$TMPDIR/marduk.env"
}

need_cmd kind
need_cmd kubectl
need_cmd docker
need_cmd curl
need_cmd python3
need_cmd base64
need_cmd helm

echo "Starting disposable External Secrets and OpenBao sync proof."
echo "No real MARDUK infrastructure or secrets are used."

if ! kind create cluster --name "$CLUSTER" --wait 120s > "$TMPDIR/kind-create.log" 2>&1; then
  cat "$TMPDIR/kind-create.log" >&2
  die "kind cluster creation failed"
fi
wait_for_kind
echo "Disposable Kubernetes cluster: ready"

kubectl --context "kind-$CLUSTER" create namespace openbao >/dev/null
kubectl --context "kind-$CLUSTER" -n openbao create serviceaccount bao-token-reviewer >/dev/null
kubectl --context "kind-$CLUSTER" create clusterrolebinding "$CLUSTER-token-reviewer" \
  --clusterrole=system:auth-delegator \
  --serviceaccount=openbao:bao-token-reviewer >/dev/null

cat > "$TMPDIR/openbao.hcl" <<'EOF'
disable_mlock = true
ui = false

storage "file" {
  path = "/bao/file"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}
EOF

mkdir -p "$TMPDIR/openbao-file"
chmod 777 "$TMPDIR/openbao-file"
docker run -d --name "$BAO_CONTAINER" --network kind \
  -p 127.0.0.1::8200 \
  -v "$TMPDIR/openbao-file:/bao/file" \
  -v "$TMPDIR/openbao.hcl:/bao/config/openbao.hcl:ro" \
  "$IMAGE" server -config=/bao/config/openbao.hcl >/dev/null

HOST_PORT=$(docker port "$BAO_CONTAINER" 8200/tcp | sed 's/.*://')
OPENBAO_ADDR="http://127.0.0.1:$HOST_PORT"
wait_for_openbao
write_env_file

echo "OpenBao disposable server: reachable"
seal_summary
INIT_CODE=$(curl -sS -o "$TMPDIR/init.json" -w '%{http_code}' \
  -X POST "$OPENBAO_ADDR/v1/sys/init" \
  --data '{"secret_shares":3,"secret_threshold":2}')
if [ "$INIT_CODE" != "200" ]; then
  sed -n '1,5p' "$TMPDIR/init.json" >&2 || true
  die "OpenBao init failed: http=$INIT_CODE"
fi
chmod 600 "$TMPDIR/init.json"
ROOT_TOKEN=$(json_get "$TMPDIR/init.json" root_token)
SHARE1=$(json_get "$TMPDIR/init.json" keys_base64.0)
SHARE2=$(json_get "$TMPDIR/init.json" keys_base64.1)

python3 - "$SHARE1" <<'PY' > "$TMPDIR/unseal-1.json"
import json
import sys

print(json.dumps({"key": sys.argv[1]}))
PY
UNSEAL1_CODE=$(curl -sS -o "$TMPDIR/unseal-1.out" -w '%{http_code}' \
  -X PUT "$OPENBAO_ADDR/v1/sys/unseal" --data @"$TMPDIR/unseal-1.json")
if [ "$UNSEAL1_CODE" != "200" ]; then
  die "OpenBao unseal share 1 failed: http=$UNSEAL1_CODE"
fi
python3 - "$SHARE2" <<'PY' > "$TMPDIR/unseal-2.json"
import json
import sys

print(json.dumps({"key": sys.argv[1]}))
PY
UNSEAL2_CODE=$(curl -sS -o "$TMPDIR/unseal-2.out" -w '%{http_code}' \
  -X PUT "$OPENBAO_ADDR/v1/sys/unseal" --data @"$TMPDIR/unseal-2.json")
if [ "$UNSEAL2_CODE" != "200" ]; then
  die "OpenBao unseal share 2 failed: http=$UNSEAL2_CODE"
fi
unset SHARE1 SHARE2
echo "OpenBao disposable server: initialized and unsealed"

starter/scripts/render-openbao-bootstrap.sh "$TMPDIR/marduk.env" "$TMPDIR/bootstrap" >/dev/null
starter/scripts/openbao-first-install.sh apply-bootstrap "$TMPDIR/marduk.env" "$TMPDIR/bootstrap" >/dev/null
echo "OpenBao bootstrap bundle: applied"

BAO_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$BAO_CONTAINER")
cat > "$TMPDIR/openbao-service.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: openbao
  namespace: openbao
spec:
  ports:
    - name: http
      port: 8200
      targetPort: 8200
---
apiVersion: v1
kind: Endpoints
metadata:
  name: openbao
  namespace: openbao
subsets:
  - addresses:
      - ip: $BAO_IP
    ports:
      - name: http
        port: 8200
EOF
kubectl --context "kind-$CLUSTER" apply -f "$TMPDIR/openbao-service.yaml" >/dev/null

if ! helm repo add external-secrets https://charts.external-secrets.io --force-update > "$TMPDIR/helm-repo.log" 2>&1; then
  cat "$TMPDIR/helm-repo.log" >&2
  die "failed to add External Secrets Helm repo"
fi
if ! helm repo update external-secrets >> "$TMPDIR/helm-repo.log" 2>&1; then
  cat "$TMPDIR/helm-repo.log" >&2
  die "failed to update External Secrets Helm repo"
fi
if ! helm upgrade --install external-secrets external-secrets/external-secrets \
  --kube-context "kind-$CLUSTER" \
  --namespace external-secrets \
  --create-namespace \
  --version "$ESO_CHART_VERSION" \
  --set installCRDs=true \
  --wait \
  --timeout 5m > "$TMPDIR/helm-install.log" 2>&1; then
  cat "$TMPDIR/helm-install.log" >&2
  die "failed to install External Secrets Operator"
fi
kubectl --context "kind-$CLUSTER" -n external-secrets rollout status deploy/external-secrets --timeout=180s >/dev/null
echo "External Secrets Operator: installed"

REVIEWER_JWT=$(kubectl --context "kind-$CLUSTER" -n openbao create token bao-token-reviewer --duration=1h)
KUBE_CA=$(kubectl --context "kind-$CLUSTER" config view --raw --minify \
  -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d)
KUBE_HOST="https://$CLUSTER-control-plane:6443"

python3 - "$KUBE_HOST" "$REVIEWER_JWT" "$KUBE_CA" "$TMPDIR/kubernetes-auth.json" <<'PY'
import json
import os
import sys

host, reviewer_jwt, kube_ca, output = sys.argv[1:5]
with open(output, "w") as f:
    json.dump({
        "kubernetes_host": host,
        "kubernetes_ca_cert": kube_ca,
        "token_reviewer_jwt": reviewer_jwt,
    }, f, indent=2)
    f.write("\n")
os.chmod(output, 0o600)
PY

starter/scripts/openbao-first-install.sh configure-kubernetes-auth \
  "$TMPDIR/marduk.env" "$TMPDIR/kubernetes-auth.json" >/dev/null
unset REVIEWER_JWT KUBE_CA
echo "OpenBao Kubernetes auth config: applied"

python3 - <<'PY' > "$TMPDIR/eso-secret.json"
import json

print(json.dumps({"data": {"token": "eso-sync-ok"}}))
PY
bao_curl POST "$ROOT_TOKEN" "marduk/data/registry/proof" "$TMPDIR/eso-secret.json" >/dev/null
echo "OpenBao proof secret: written"

kubectl --context "kind-$CLUSTER" create namespace demo >/dev/null
cat > "$TMPDIR/eso-objects.yaml" <<'EOF'
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: openbao
spec:
  provider:
    vault:
      server: "http://openbao.openbao.svc:8200"
      path: "marduk"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "eso"
          serviceAccountRef:
            name: "external-secrets"
            namespace: "external-secrets"
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: registry-proof
  namespace: demo
spec:
  refreshInterval: 10s
  secretStoreRef:
    kind: ClusterSecretStore
    name: openbao
  target:
    name: registry-proof
    creationPolicy: Owner
  data:
    - secretKey: token
      remoteRef:
        key: registry/proof
        property: token
EOF
kubectl --context "kind-$CLUSTER" apply -f "$TMPDIR/eso-objects.yaml" >/dev/null

kubectl --context "kind-$CLUSTER" wait clustersecretstore/openbao \
  --for=condition=Ready --timeout=180s >/dev/null
kubectl --context "kind-$CLUSTER" -n demo wait externalsecret/registry-proof \
  --for=condition=Ready --timeout=180s >/dev/null
SYNCED_VALUE=$(kubectl --context "kind-$CLUSTER" -n demo get secret registry-proof \
  -o jsonpath='{.data.token}' | base64 -d)
if [ "$SYNCED_VALUE" != "eso-sync-ok" ]; then
  die "ExternalSecret target value mismatch"
fi
unset SYNCED_VALUE

ROOT_REVOKE_CODE=$(curl -sS -o "$TMPDIR/revoke-root.out" -w '%{http_code}' \
  -X POST -H "X-Vault-Token: $ROOT_TOKEN" "$OPENBAO_ADDR/v1/auth/token/revoke-self")
unset ROOT_TOKEN
if [ "$ROOT_REVOKE_CODE" != "204" ]; then
  die "root token revoke failed: http=$ROOT_REVOKE_CODE"
fi

echo "External Secrets sync proof: PASS"
echo "kind_cluster_created=true external_secrets_installed=true clustersecretstore_ready=true externalsecret_synced=true target_secret_verified=true"
echo "unseal_shares_printed=false token_reviewer_jwt_printed=false service_account_jwt_printed=false vault_tokens_printed=false"
