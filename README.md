# socksmyvpn

*Better* docs pending

## Example

```
docker run \
    --rm \
    -it \
    --name vpn \
    --privileged \
    --cap-add=NET_ADMIN \
    -p 0.0.0.0:1080:1080 \
    --volume "/home//.vpncfg:/vpn/:ro" \
    -e SOCKS_USER=test \
    -e SOCKS_PASSWORD=123 \
    socksmyvpn
```

`curl -x socks5://test:123@127.0.0.1:1080 https://ipinfo.io`

You can remove SOCKS_USER and SOCKS_PASSWORD and there will be no auth.

## Volume

Mount a volume like `--volume "FOLDER:/vpn/:ro"` where the `FOLDER` is a folder containing OpenVPN configs (.ovpn or .cfg)

The client by default will select the first `.conf` file it finds (*.conf). You can choose a OpenVPN config by using the `OPENVPN_CONFIG` environment variable.  
`-e OPENVPN_CONFIG=australia.ovpn`

## Default environment variables

SOCKS_LISTEN_IP=0.0.0.0  
SOCKS_PORT=1080  
SOCKS_USER=  
SOCKS_PASSWORD=  
LOCAL_NETWORK=  
OPENVPN_CONFIG=*.conf  
DONT_KILL_SOCKS_SERVER_ON_DISCONNECT=  

Changes to `SOCKS_LISTEN_IP` and `SOCKS_PORT` aren't useful, just do it in Docker under `-p`.

## LOCAL_NETWORK

If you want to connect to the SOCKS server over LAN/Internet you will need to pass in subnets or addresses which you want to whitelist from OpenVPN, otherwise you won't be able to connect (connection refused).  
This isn't needed for localhost.  
`-e LOCAL_NETWORK=10.10.10.0/24,34.34.34.34`

You can do IPs or ranges like above separated by comma

## DONT_KILL_SOCKS_SERVER_ON_DISCONNECT

When we lose connection to OpenVPN by default the SOCKS server will stop. You can disable this behaviour by setting this environment variable to ANY value (should probably just be `true` :/)

This is because we bind the SOCKS server to the private IP of the OpenVPN interface, and on reconnect this can change. Kind of lazy but the SOCKS server isn't very helpful when the OpenVPN connection is down anyway. In the future I might have it auto-detect changes to the private IP and restart the SOCKS server in order to solve this issue.

**Note that if the private IP changes on OpenVPN then the SOCKS server will not work**
