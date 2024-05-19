#!/usr/bin/env bash

set -eu -o pipefail

cmd="$1" # up / down
shift
# https://openvpn.net/community-resources/reference-manual-for-openvpn-2-1/
# cmd tundevev tun_mtu link_mtu ifconfig_local_ip ifconfig_remote_ip [ init | restart ]
tun="$1"
tun_ip="$4"

[ -f /etc/openvpn/"$cmd".sh ] && /etc/openvpn/"$cmd".sh "$@"

is_running() {
    [[ -f /microsocks.pid ]] && kill -0 "$(cat /microsocks.pid)" &>/dev/null
}

start_microsocks() {
    args=(
        -b
        "$tun_ip"
        -q
    )
	if [[ -n "$SOCKS_USERNAME" ]] && [[ -n "$SOCKS_PASSWORD" ]]; then
        args+=(
            -u
            "$SOCKS_USERNAME"
            -P
            "$SOCKS_PASSWORD"
        )
    fi
    if (( SOCKS_AUTH_ONCE )); then
        args+=(
            -1
        )
    fi
    nohup microsocks "${args[@]}" &>/dev/null &
    echo "$!" > /microsocks.pid
}

kill_microsocks() {
    if [ -f /microsocks.pid ]; then
        kill -9 "$(cat /microsocks.pid)" || true
        rm /microsocks.pid
    fi
}

routes() {
    route_cmd="$1"
	if [[ -n "${LOCAL_NETWORK-}" ]]; then
        ip route list match 0.0.0.0 | while read -r _route; do
            read gateway dev <<<"$(<<<"$_route" cut -f3,5 -d ' ')"
            if [[ "$dev" == "$tun" ]]; then
                continue
            fi
			for net in ${LOCAL_NETWORK//,/ }; do
                echo "$route_cmd route to local network $net via $gateway dev $dev" >&2
                ip route "$route_cmd" "$net" via "$gateway" dev "$dev"
			done
        done
	fi
}


case "$cmd" in
    up)
        if ! is_running; then
            routes add
            start_microsocks
        fi
        ;;
    down)
        kill_microsocks
        routes del
        ;;
    *) echo "Unknown cmd: $cmd" >&2; exit 1 ;;
esac
