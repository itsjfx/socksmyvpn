# Stage 1 - base image
FROM alpine:latest as builder
# Get GCC and git
RUN apk add git build-base make --no-cache --update
# Get microsocks
RUN git clone https://github.com/rofl0r/microsocks msocks
# Make
WORKDIR msocks
RUN make
# Move
RUN mkdir /build
RUN mv microsocks /build

# Stage 2 - run
FROM alpine:latest
# Get our deps, upgrade grep for the start_server script
RUN apk add openvpn bash procps --no-cache --update --upgrade grep
RUN rm -rf /tmp/* /var/cache/apk/*
# Get our built version of microsocks
COPY --from=builder /build /build
# Setup scripts
COPY start_server.sh /start_server.sh
RUN chmod +x /start_server.sh
COPY kill_server.sh /kill_server.sh
RUN chmod +x /kill_server.sh
COPY dump_env.sh /dump_env.sh
RUN chmod +x /dump_env.sh
EXPOSE 1080/tcp
# Environment
ENV SOCKS_LISTEN_IP=0.0.0.0
ENV SOCKS_PORT=1080
ENV SOCKS_USER=
ENV SOCKS_PASSWORD=
ENV LOCAL_NETWORK=
ENV OPENVPN_CONFIG=*.conf
ENV DONT_KILL_SOCKS_SERVER_ON_DISCONNECT=
# Entrypoint
ENTRYPOINT ["/bin/bash", "-c", "/dump_env.sh && cd /vpn && /usr/sbin/openvpn --config /vpn/$OPENVPN_CONFIG --script-security 2 --up /start_server.sh --down /kill_server.sh && /kill_server.sh kill"]
