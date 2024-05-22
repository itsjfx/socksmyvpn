FROM alpine:latest as builder
RUN apk add git build-base make --no-cache --update && \
    git clone https://github.com/rofl0r/microsocks microsocks && \
    cd microsocks && \
    make

FROM alpine:latest
RUN apk add openvpn bash procps --no-cache --update --upgrade grep
COPY --from=builder /microsocks/microsocks /usr/local/bin/microsocks
COPY handler.sh /handler.sh
COPY entrypoint.sh /entrypoint.sh

ENV SOCKS_USERNAME=
ENV SOCKS_PASSWORD=
ENV SOCKS_AUTH_ONCE=0
ENV LOCAL_NETWORK=
ENV OPENVPN_CONFIG=*.conf

LABEL org.opencontainers.image.source https://github.com/itsjfx/socksmyvpn

ENTRYPOINT ["/entrypoint.sh"]
