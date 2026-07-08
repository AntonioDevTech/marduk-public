#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT"

EDGE_PROXY_IMAGE="${EDGE_PROXY_IMAGE:-nginx:1.29-alpine}"
STAMP=$(date +%s)
NETWORK="marduk-edge-proof-$STAMP-$$"
HELLO_IMAGE="marduk-edge-hello:$STAMP-$$"
HELLO_CONTAINER="marduk-edge-hello-$STAMP-$$"
EDGE_CONTAINER="marduk-edge-proxy-$STAMP-$$"
TMPDIR=$(mktemp -d "${TMPDIR:-/tmp}/marduk-edge-proof.XXXXXX")

die() {
  echo "ERROR: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

cleanup() {
  set +e
  docker rm -f "$EDGE_CONTAINER" "$HELLO_CONTAINER" >/dev/null 2>&1 || true
  docker network rm "$NETWORK" >/dev/null 2>&1 || true
  docker rmi "$HELLO_IMAGE" >/dev/null 2>&1 || true
  rm -rf "$TMPDIR"
}

trap cleanup EXIT INT TERM

need_cmd docker
need_cmd curl

echo "Starting disposable public-edge proof."
echo "No real DNS, Cloudflare account, tunnel token, or public route is used."

cat > "$TMPDIR/nginx.conf" <<'EOF'
events {}

http {
  server {
    listen 8080 default_server;
    return 404;
  }

  server {
    listen 8080;
    server_name hello.example.invalid;

    location / {
      proxy_pass http://hello:8080;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-Proto http;
    }
  }
}
EOF

docker network create "$NETWORK" >/dev/null
if ! docker build -q -t "$HELLO_IMAGE" apps/hello > "$TMPDIR/hello-build.log" 2>&1; then
  cat "$TMPDIR/hello-build.log" >&2
  die "hello image build failed"
fi
docker run -d --name "$HELLO_CONTAINER" --network "$NETWORK" --network-alias hello \
  "$HELLO_IMAGE" >/dev/null
if ! docker run -d --name "$EDGE_CONTAINER" --network "$NETWORK" \
  -p 127.0.0.1::8080 \
  -v "$TMPDIR/nginx.conf:/etc/nginx/nginx.conf:ro" \
  "$EDGE_PROXY_IMAGE" > "$TMPDIR/edge-run.log" 2>&1; then
  cat "$TMPDIR/edge-run.log" >&2
  die "edge proxy container failed to start"
fi

EDGE_PORT=$(docker port "$EDGE_CONTAINER" 8080/tcp | sed 's/.*://')

i=0
while [ "$i" -lt 60 ]; do
  if curl -fsS -H 'Host: hello.example.invalid' "http://127.0.0.1:$EDGE_PORT/healthz" >/dev/null 2>&1; then
    break
  fi
  i=$((i + 1))
  sleep 1
done
if [ "$i" -ge 60 ]; then
  docker logs "$HELLO_CONTAINER" >&2 || true
  docker logs "$EDGE_CONTAINER" >&2 || true
  die "edge proxy did not route hello healthz"
fi

HELLO_HTTP=$(curl -sS -o "$TMPDIR/hello.out" -w '%{http_code}' \
  -H 'Host: hello.example.invalid' "http://127.0.0.1:$EDGE_PORT/")
HEALTH_HTTP=$(curl -sS -o "$TMPDIR/health.out" -w '%{http_code}' \
  -H 'Host: hello.example.invalid' "http://127.0.0.1:$EDGE_PORT/healthz")
UNKNOWN_HTTP=$(curl -sS -o "$TMPDIR/unknown.out" -w '%{http_code}' \
  -H 'Host: unknown.example.invalid' "http://127.0.0.1:$EDGE_PORT/" || true)

if [ "$HELLO_HTTP" != "200" ]; then
  die "expected hello route HTTP 200, got $HELLO_HTTP"
fi
if [ "$HEALTH_HTTP" != "200" ]; then
  die "expected hello healthz HTTP 200, got $HEALTH_HTTP"
fi
if ! grep -qx 'ok' "$TMPDIR/health.out"; then
  die "expected healthz body ok"
fi
if [ "$UNKNOWN_HTTP" != "404" ]; then
  die "expected unknown host HTTP 404, got $UNKNOWN_HTTP"
fi

echo "Public-edge proof: PASS"
echo "hello_host=hello.example.invalid hello_http=200 healthz_http=200 healthz_body=ok unknown_host_http=404 edge_proxy=pinned-nginx tunnel_tokens_used=false dns_tokens_used=false"
