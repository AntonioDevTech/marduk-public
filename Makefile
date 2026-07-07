.PHONY: test run docker-build

test:
	cd apps/hello && go test ./...

run:
	cd apps/hello && go run .

docker-build:
	docker build -t marduk-hello:local apps/hello
