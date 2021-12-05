FROM caddy:2.4.6-builder AS builder

RUN xcaddy build \
  --with github.com/lucaslorentz/caddy-docker-proxy/plugin

FROM caddy:2.4.6
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
CMD [ "caddy", "docker-proxy" ]