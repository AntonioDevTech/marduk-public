FROM golang:1.26-alpine AS build
WORKDIR /src
COPY go.mod main.go ./
RUN CGO_ENABLED=0 go build -trimpath -o /hello .

FROM alpine:3.22
RUN adduser -D -u 10001 hello
USER 10001
COPY --from=build /hello /hello
EXPOSE 8080
ENTRYPOINT ["/hello"]
