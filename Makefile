.PHONY: doctor test run docker-build

doctor:
	@command -v go >/dev/null || { echo "missing: go (install Go, then rerun make doctor)"; exit 1; }
	@command -v docker >/dev/null || echo "optional missing: docker (needed only for make docker-build)"
	@echo "developer tools: OK"

test:
	cd apps/hello && go test ./...

run:
	cd apps/hello && go run .

docker-build:
	docker build -t marduk-hello:local apps/hello
