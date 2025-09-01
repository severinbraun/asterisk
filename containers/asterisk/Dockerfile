# syntax=docker/dockerfile:1.9
FROM alpine:3.20

ARG OWNER=severinbraun
LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${OWNER}" \
      org.opencontainers.image.title="${REPO}" \
      org.opencontainers.image.licenses="MIT"

RUN adduser -D app
USER app
WORKDIR /app

COPY --chown=app:app entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

HEALTHCHECK --interval=30s --timeout=3s CMD [ "sh", "-c", "echo ok" ]

ENTRYPOINT ["/app/entrypoint.sh"]
