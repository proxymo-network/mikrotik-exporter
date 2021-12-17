FROM debian:9.9-slim

EXPOSE 9436

COPY scripts/start.sh /app/
COPY dist/mikrotik-exporter_linux_amd64 /app/mikrotik-exporter

RUN chmod 755 /app/*

# Reference: https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.source="https://github.com/proxymo-network/mikrotik-exporter"


ENTRYPOINT ["/app/start.sh"]