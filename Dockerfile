#syntax=docker/dockerfile:1.2

# build static binary
FROM golang:1.17.5-alpine3.15 as builder 


WORKDIR /go/src/github.com/proxymo-network/mikrotik-exporter


# download dependencies 
COPY go.mod go.sum ./
RUN go mod download 

COPY . .

# git tag 
ARG BUILD_VERSION

# git commit sha
ARG BUILD_REF

# build time 
ARG BUILD_TIME

# compile 
RUN CGO_ENABLED=0 go build \
    -ldflags="-w -s -extldflags \"-static\" -X \"main.appVersion=${BUILD_VERSION}\" -X \"main.shortSha=${BUILD_REF}\" -X \"main.date=${BUILD_TIME}\"" \
    -a \
    -tags timetzdata \
    -o /bin/mikrotik-export .


# run 
FROM alpine:3.15

RUN apk add --no-cache curl=7.80.0-r0

COPY --from=builder /bin/mikrotik-export /bin/mikrotik-export

EXPOSE 8000

ARG BULD_VERSION
ARG BUILD_REF
ARG BUILD_TIME

# Reference: https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.source="https://github.com/proxymo-network/mikrotik-exporter"

EXPOSE 9436

HEALTHCHECK --interval=30s \
    --timeout=30s \
    --start-period=2s \
    --retries=3 \
    CMD curl --request POST \
    --fail \
    --show-error \
    --url http://localhost:9436/healthz \
    --header 'Content-Type: application/json' \
    --data '{}'

ENTRYPOINT [ "/bin/mikrotik-export" ]
