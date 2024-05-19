#!/usr/bin/env bash

set -eu -o pipefail

mkdir -p /dev/net
# avoids needing privileged mode
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi
cd /vpn
/usr/sbin/openvpn \
    --config /vpn/$OPENVPN_CONFIG \
    --script-security 2 \
    --up "/handler.sh up" \
    --down "/handler.sh down" \
    --setenv SOCKS_USERNAME "$SOCKS_USERNAME" \
    --setenv SOCKS_PASSWORD "$SOCKS_PASSWORD" \
    --setenv SOCKS_AUTH_ONCE "$SOCKS_AUTH_ONCE" \
    --setenv LOCAL_NETWORK "$LOCAL_NETWORK" \
