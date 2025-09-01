# syntax=docker/dockerfile:1.9
FROM alpine:3.20

# Diese ARGs bekommen ihre Werte aus der GitHub Action (build-args)
ARG OWNER
ARG REPO

# Labels dürfen die ARGs referenzieren (falls leer, bleiben sie eben leer)
LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.title="${REPO}" \
      org.opencontainers.image.licenses="MIT"

# schlanker, nicht-root User
RUN adduser -D app
USER app
WORKDIR /app

COPY --chown=app:app entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

HEALTHCHECK --interval=30s --timeout=3s CMD ["sh","-c","echo ok"]

ENTRYPOINT ["/app/entrypoint.sh"]
