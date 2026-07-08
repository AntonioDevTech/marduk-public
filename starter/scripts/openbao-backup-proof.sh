#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT"

OPENBAO_IMAGE="${OPENBAO_IMAGE:-openbao/openbao:2.5.5}"
BACKUP_BASE_IMAGE="${BACKUP_BASE_IMAGE:-alpine:3.22}"
STAMP=$(date +%s)
BAO_CONTAINER="marduk-backup-bao-$STAMP-$$"
BACKUP_IMAGE="marduk-backup-receiver:$STAMP-$$"
BACKUP_CONTAINER="marduk-backup-receiver-$STAMP-$$"
TMPDIR=$(mktemp -d "${TMPDIR:-/tmp}/marduk-backup-proof.XXXXXX")
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
    docker run --rm -v "$TMPDIR:/proof" "$BACKUP_BASE_IMAGE" sh -c \
      'rm -rf /proof/* /proof/.[!.]* /proof/..?*' >/dev/null 2>&1 || true
    rmdir "$TMPDIR" >/dev/null 2>&1 || true
  fi
}

cleanup() {
  set +e
  docker rm -f "$BAO_CONTAINER" "$BACKUP_CONTAINER" >/dev/null 2>&1 || true
  docker rmi "$BACKUP_IMAGE" >/dev/null 2>&1 || true
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

wait_for_active_openbao() {
  i=0
  while [ "$i" -lt 60 ]; do
    code=$(curl -sS -o /dev/null -w '%{http_code}' \
      "$OPENBAO_ADDR/v1/sys/health?standbyok=false&perfstandbyok=false&sealedcode=503&uninitcode=503" \
      2>/dev/null || true)
    if [ "$code" = "200" ]; then
      return 0
    fi
    i=$((i + 1))
    sleep 1
  done
  docker logs "$BAO_CONTAINER" >&2 || true
  die "OpenBao did not become active leader"
}

wait_for_ssh() {
  i=0
  while [ "$i" -lt 60 ]; do
    if ssh-keyscan -p "$BACKUP_PORT" 127.0.0.1 > "$TMPDIR/known_hosts" 2>/dev/null; then
      return 0
    fi
    i=$((i + 1))
    sleep 1
  done
  docker logs "$BACKUP_CONTAINER" >&2 || true
  die "backup receiver SSH did not become reachable"
}

need_cmd docker
need_cmd curl
need_cmd python3
need_cmd ssh
need_cmd ssh-keygen
need_cmd ssh-keyscan
need_cmd sha256sum

echo "Starting disposable OpenBao backup proof."
echo "No real MARDUK infrastructure or secrets are used."

cat > "$TMPDIR/openbao.hcl" <<'EOF'
disable_mlock = true
ui = false
api_addr = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"

storage "raft" {
  path = "/bao/raft"
  node_id = "public-backup-proof"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable = 1
}
EOF

mkdir -p "$TMPDIR/openbao-raft"
chmod 777 "$TMPDIR/openbao-raft"
docker run -d --name "$BAO_CONTAINER" \
  -p 127.0.0.1::8200 \
  -v "$TMPDIR/openbao-raft:/bao/raft" \
  -v "$TMPDIR/openbao.hcl:/bao/config/openbao.hcl:ro" \
  "$OPENBAO_IMAGE" server -config=/bao/config/openbao.hcl >/dev/null

HOST_PORT=$(docker port "$BAO_CONTAINER" 8200/tcp | sed 's/.*://')
OPENBAO_ADDR="http://127.0.0.1:$HOST_PORT"
wait_for_openbao
echo "OpenBao disposable raft server: reachable"

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
curl -fsS -X PUT "$OPENBAO_ADDR/v1/sys/unseal" --data @"$TMPDIR/unseal-1.json" >/dev/null
python3 - "$SHARE2" <<'PY' > "$TMPDIR/unseal-2.json"
import json
import sys

print(json.dumps({"key": sys.argv[1]}))
PY
curl -fsS -X PUT "$OPENBAO_ADDR/v1/sys/unseal" --data @"$TMPDIR/unseal-2.json" >/dev/null
unset SHARE1 SHARE2
echo "OpenBao disposable raft server: initialized and unsealed"
wait_for_active_openbao
echo "OpenBao active leader: ready"

curl -fsS -X POST -H "X-Vault-Token: $ROOT_TOKEN" \
  --data '{"type":"kv","options":{"version":"2"}}' \
  "$OPENBAO_ADDR/v1/sys/mounts/marduk" >/dev/null
python3 - <<'PY' > "$TMPDIR/proof-secret.json"
import json

print(json.dumps({"data": {"proof": "public-safe-backup-proof"}}))
PY
curl -fsS -X POST -H "X-Vault-Token: $ROOT_TOKEN" \
  --data @"$TMPDIR/proof-secret.json" \
  "$OPENBAO_ADDR/v1/marduk/data/proof/backup" >/dev/null

SNAPSHOT="$TMPDIR/marduk-public-backup-proof.snap"
SNAP_CODE=$(curl -sS -o "$SNAPSHOT" -w '%{http_code}' \
  -H "X-Vault-Token: $ROOT_TOKEN" \
  "$OPENBAO_ADDR/v1/sys/storage/raft/snapshot")
if [ "$SNAP_CODE" != "200" ]; then
  die "raft snapshot failed: http=$SNAP_CODE"
fi
SNAP_SIZE=$(wc -c < "$SNAPSHOT" | tr -d ' ')
if [ "$SNAP_SIZE" -le 2000 ]; then
  die "raft snapshot unexpectedly small: bytes=$SNAP_SIZE"
fi
SNAP_SHA=$(sha256sum "$SNAPSHOT" | awk '{print $1}')
echo "OpenBao raft snapshot: saved"

BUILD_DIR="$TMPDIR/backup-receiver-build"
mkdir -p "$BUILD_DIR"

ssh-keygen -q -t ed25519 -N "" -f "$TMPDIR/ship_key" >/dev/null
PUBKEY=$(cat "$TMPDIR/ship_key.pub")
cat > "$BUILD_DIR/recv-snapshot" <<'EOF'
#!/bin/sh
set -eu
umask 077
dest=/var/backups/openbao
mkdir -p "$dest"
tmp="$dest/.incoming.$$"
out="$dest/marduk-public-$(date -u +%Y%m%d%H%M%S).snap"
dd bs=1M count=100 of="$tmp" status=none
bytes=$(wc -c < "$tmp" | tr -d " ")
if [ "$bytes" -le 0 ]; then
  rm -f "$tmp"
  echo "ERROR empty snapshot" >&2
  exit 1
fi
mv "$tmp" "$out"
ls -1t "$dest"/marduk-public-*.snap 2>/dev/null | tail -n +15 | xargs -r rm -f
printf 'OK %s %s\n' "$out" "$bytes"
EOF
chmod +x "$BUILD_DIR/recv-snapshot"

cat > "$BUILD_DIR/Dockerfile" <<EOF
FROM $BACKUP_BASE_IMAGE
RUN apk add --no-cache openssh-server shadow \\
    && adduser -D -h /home/baoship -s /bin/sh baoship \\
    && echo 'baoship:public-proof-disabled-password' | chpasswd \\
    && mkdir -p /run/sshd /home/baoship/.ssh /var/backups/openbao \\
    && ssh-keygen -A
COPY recv-snapshot /usr/local/bin/recv-snapshot
RUN chown root:root /usr/local/bin/recv-snapshot \\
    && chmod 755 /usr/local/bin/recv-snapshot \\
    && chown -R baoship:baoship /home/baoship \\
    && chown -R baoship:baoship /var/backups/openbao
RUN printf '%s\n' \\
  'Port 2222' \\
  'PasswordAuthentication no' \\
  'PermitRootLogin no' \\
  'PubkeyAuthentication yes' \\
  'AuthorizedKeysFile .ssh/authorized_keys' \\
  'AllowUsers baoship' \\
  'LogLevel VERBOSE' > /etc/ssh/sshd_config
RUN printf '%s %s\n' 'command="/usr/local/bin/recv-snapshot",no-agent-forwarding,no-X11-forwarding,no-port-forwarding,no-pty' '$PUBKEY' > /home/baoship/.ssh/authorized_keys \\
    && chown baoship:baoship /home/baoship/.ssh/authorized_keys \\
    && chmod 600 /home/baoship/.ssh/authorized_keys
EXPOSE 2222
CMD ["/usr/sbin/sshd", "-D", "-e"]
EOF

if ! docker build -q -t "$BACKUP_IMAGE" "$BUILD_DIR" > "$TMPDIR/backup-build.log" 2>&1; then
  cat "$TMPDIR/backup-build.log" >&2
  die "backup receiver image build failed"
fi
docker run -d --name "$BACKUP_CONTAINER" -p 127.0.0.1::2222 "$BACKUP_IMAGE" >/dev/null
BACKUP_PORT=$(docker port "$BACKUP_CONTAINER" 2222/tcp | sed 's/.*://')
wait_for_ssh
chmod 600 "$TMPDIR/known_hosts" "$TMPDIR/ship_key"
echo "Disposable backup receiver: reachable"

SHIP_OUTPUT=$(ssh -i "$TMPDIR/ship_key" -p "$BACKUP_PORT" \
  -o IdentitiesOnly=yes \
  -o StrictHostKeyChecking=yes \
  -o UserKnownHostsFile="$TMPDIR/known_hosts" \
  baoship@127.0.0.1 recv-snapshot < "$SNAPSHOT")
case "$SHIP_OUTPUT" in
  OK\ *)
    ;;
  *)
    die "snapshot ship returned unexpected output"
    ;;
esac

REMOTE_INFO=$(docker exec "$BACKUP_CONTAINER" sh -c 'set -eu; f=$(ls -1t /var/backups/openbao/marduk-public-*.snap | head -1); printf "%s %s %s\n" "$(basename "$f")" "$(wc -c < "$f" | tr -d " ")" "$(sha256sum "$f" | cut -d " " -f 1)"')
REMOTE_NAME=$(printf '%s' "$REMOTE_INFO" | awk '{print $1}')
REMOTE_SIZE=$(printf '%s' "$REMOTE_INFO" | awk '{print $2}')
REMOTE_SHA=$(printf '%s' "$REMOTE_INFO" | awk '{print $3}')
if [ "$REMOTE_SIZE" != "$SNAP_SIZE" ] || [ "$REMOTE_SHA" != "$SNAP_SHA" ]; then
  die "shipped snapshot mismatch: local_size=$SNAP_SIZE remote_size=$REMOTE_SIZE"
fi

set +e
ssh -i "$TMPDIR/ship_key" -p "$BACKUP_PORT" \
  -o IdentitiesOnly=yes \
  -o StrictHostKeyChecking=yes \
  -o UserKnownHostsFile="$TMPDIR/known_hosts" \
  baoship@127.0.0.1 uname -a </dev/null > "$TMPDIR/negative.out" 2>&1
NEG_CODE=$?
set -e
if grep -qi 'linux' "$TMPDIR/negative.out"; then
  die "forced-command negative proof failed: arbitrary command output appeared"
fi

ROOT_REVOKE_CODE=$(curl -sS -o "$TMPDIR/revoke-root.out" -w '%{http_code}' \
  -X POST -H "X-Vault-Token: $ROOT_TOKEN" "$OPENBAO_ADDR/v1/auth/token/revoke-self")
unset ROOT_TOKEN
if [ "$ROOT_REVOKE_CODE" != "204" ]; then
  die "root token revoke failed: http=$ROOT_REVOKE_CODE"
fi

echo "OpenBao backup proof: PASS"
echo "raft_snapshot_created=true snapshot_bytes=$SNAP_SIZE snapshot_shipped=true remote_file=$REMOTE_NAME sha256_match=true forced_command_enforced=true negative_ssh_exit=$NEG_CODE"
echo "seed_values_printed=false unseal_shares_printed=false vault_tokens_printed=false ssh_private_key_printed=false"
