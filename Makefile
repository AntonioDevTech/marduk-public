GO_DOCKER_IMAGE ?= golang:1.26-alpine

.PHONY: doctor test test-local test-docker run run-docker docker-build starter-doctor public-plan starter-tfvars openbao-plan openbao-bootstrap openbao-first-install-dry-run openbao-kubernetes-login-proof openbao-eso-sync-proof openbao-secret-seeding-proof openbao-backup-proof public-edge-proof

doctor:
	@if command -v go >/dev/null; then \
		echo "go: OK"; \
	elif command -v docker >/dev/null; then \
		echo "go: missing; Docker fallback available for make test"; \
	else \
		echo "missing: install Go or Docker"; exit 1; \
	fi
	@command -v docker >/dev/null || echo "optional missing: docker (needed for make test fallback and make docker-build)"
	@echo "developer tools: OK"

test:
	@if command -v go >/dev/null; then \
		$(MAKE) test-local; \
	else \
		$(MAKE) test-docker; \
	fi

test-local:
	cd apps/hello && go test ./...

test-docker:
	docker run --rm -v "$$(pwd)/apps/hello:/src" -w /src $(GO_DOCKER_IMAGE) go test ./...

run:
	cd apps/hello && go run .

run-docker: docker-build
	docker run --rm -p 8080:8080 marduk-hello:local

docker-build:
	docker build -t marduk-hello:local apps/hello

starter-doctor:
	starter/scripts/doctor.sh starter/config/marduk.env.example --allow-placeholders

public-plan:
	./deploy-marduk-public.sh plan

starter-tfvars:
	./deploy-marduk-public.sh render-terraform starter/config/marduk.env.example -

openbao-plan:
	./deploy-marduk-public.sh openbao-plan

openbao-bootstrap:
	rm -rf /tmp/marduk-openbao-bootstrap
	./deploy-marduk-public.sh render-openbao starter/config/marduk.env.example /tmp/marduk-openbao-bootstrap
	test -f /tmp/marduk-openbao-bootstrap/policies/eso-ro.hcl
	test -f /tmp/marduk-openbao-bootstrap/payloads/kubernetes-role-eso.json

openbao-first-install-dry-run:
	./deploy-marduk-public.sh openbao-first-install-dry-run

openbao-kubernetes-login-proof:
	starter/scripts/openbao-kubernetes-login-proof.sh

openbao-eso-sync-proof:
	starter/scripts/openbao-eso-sync-proof.sh

openbao-secret-seeding-proof:
	starter/scripts/openbao-secret-seeding-proof.sh

openbao-backup-proof:
	starter/scripts/openbao-backup-proof.sh

public-edge-proof:
	starter/scripts/public-edge-proof.sh
