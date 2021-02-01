#!/bin/bash

# Grab the env variables we dumped earlier
source /env_dump

# Run the openvpn down.sh if it's there
[ -f /etc/openvpn/down.sh ] && /etc/openvpn/down.sh "$@"

if [[ -z "$DONT_KILL_SOCKS_SERVER_ON_DISCONNECT" ]] || [[ -n "$DONT_KILL_SOCKS_SERVER_ON_DISCONNECT" && "$1" == "kill" ]]; then
	# Delete routes
	# https://github.com/haugene/docker-transmission-openvpn/blob/75d0b53642cb4d8076b4d28d79407a1840bf73c2/openvpn/start.sh
	eval $(/sbin/ip route list match 0.0.0.0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}')
	if [[ -n "${LOCAL_NETWORK-}" ]]; then
		if [[ -n "${GW-}" ]] && [[ -n "${INT-}" ]]; then
			for localNet in ${LOCAL_NETWORK//,/ }; do
				route_status=$(/sbin/ip route show "${localNet}" via "${GW}" dev "${INT}")
				if [[ -n "$route_status" ]]; then
					echo "Deleting route to local network ${localNet} via ${GW} dev ${INT}"
					/sbin/ip route del "${localNet}" via "${GW}" dev "${INT}"
				fi
			done
		fi
	fi
	
	# Kill any running socks servers
	for pid in $(pgrep microsocks -r SR); do kill -9 $pid; done
fi
