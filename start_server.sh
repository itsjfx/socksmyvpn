#!/bin/bash
set -e

# Grab the env variables we dumped earlier
source /env_dump

# Run the openvpn up.sh if it's there
[ -f /etc/openvpn/up.sh ] && /etc/openvpn/up.sh "$@"

# Only start if there's no running socks servers
if [[ -n "pgrep microsocks -r SR" ]]; then
	# Add local network routes
	# https://github.com/haugene/docker-transmission-openvpn/blob/75d0b53642cb4d8076b4d28d79407a1840bf73c2/openvpn/start.sh
	eval $(/sbin/ip route list match 0.0.0.0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}')
	if [[ -n "${LOCAL_NETWORK-}" ]]; then
		if [[ -n "${GW-}" ]] && [[ -n "${INT-}" ]]; then
			for localNet in ${LOCAL_NETWORK//,/ }; do
				route_status=$(/sbin/ip route show "${localNet}" via "${GW}" dev "${INT}")
				if [[ -z "$route_status" ]]; then
					echo "Adding route to local network ${localNet} via ${GW} dev ${INT}"
					/sbin/ip route add "${localNet}" via "${GW}" dev "${INT}"
				fi
			done
		fi
	fi

	# Get the IP of tun0 to bind the socks proxy to
	IP=$(ip -4 addr show tun0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
	if [[ -n "$SOCKS_USER" ]] && [[ -n "$SOCKS_PASSWORD" ]]; then
		nohup /build/microsocks -i $SOCKS_LISTEN_IP -p $SOCKS_PORT -b $IP -u $SOCKS_USER -P $SOCKS_PASSWORD >/dev/null 2>&1 &
	else
		nohup /build/microsocks -i $SOCKS_LISTEN_IP -p $SOCKS_PORT -b $IP >/dev/null 2>&1 &
	fi
fi
