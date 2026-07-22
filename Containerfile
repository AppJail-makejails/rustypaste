ARG FREEBSD_RELEASE

FROM ghcr.io/appjail-makejails/core:${FREEBSD_RELEASE}

ARG NO_PKGCLEAN

LABEL org.opencontainers.image.title="rustypaste" \
    org.opencontainers.image.description="Minimal file upload/pastebin service" \
    org.opencontainers.image.source="https://github.com/AppJail-makejails/rustypaste" \
    org.opencontainers.image.url="https://github.com/AppJail-makejails/rustypaste" \
    org.opencontainers.image.vendor="DtxdF" \
    org.opencontainers.image.authors="Jesús Daniel Colmenares Oviedo <dtxdf@disroot.org>"

RUN set -xe; \
    \
    pkg update; \
    pkg install -U rustypaste; \
    \
    if [ -z "${NO_PKGCLEAN}" ]; then \
        pkg clean -a; \
        rm -rf /var/cache/pkg/*; \
    fi; \
    rm -rf /var/db/pkg/repos/*

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh && \
    mkdir -p /app && \
    chmod 700 /app

WORKDIR /app

COPY config.toml .

RUN chmod 444 config.toml

ENV SERVER__ADDRESS=0.0.0.0:8000

VOLUME ["/app/upload"]

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
