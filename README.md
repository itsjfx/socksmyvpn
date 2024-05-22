# socksmyvpn

This image connects to an OpenVPN server and runs a SOCKS5 proxy
([microsocks](https://github.com/rofl0r/microsocks)).

This allows you to tunnel through an OpenVPN network without impacting your
machines routing or DNS.

Some features:
* can enable SOCKS5 password authentication. by default no authentication is
  used
* if authentication is enabled, can optionally enable auth once mode in
  `microsocks`, meaning previously authenticated clients no longer need to
  re-authenticate
    * see:
      <https://github.com/rofl0r/microsocks/blob/master/README.md#command-line-options>
* you can specify ip addresses (other than `localhost`) which are allowed to
  connect to the socks proxy with `LOCAL_NETWORK`
    * by default OpenVPN will get in the way of connections from `microsocks`
      back to a client
    * this is handy if you want to use the proxy from multiple machines on your
      LAN
* `microsocks` is always bound to the OpenVPN tunnel device, reducing the chance
  of an IP leak
* socks server is shut down on OpenVPN disconnect

## Example

You MUST specify `cap-add=NET_ADMIN`

```bash
docker run \
    --rm \
    -it \
    --name vpn \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    --cap-add=NET_ADMIN \
    -p 0.0.0.0:1080:1080 \
    --volume "openvpncfg:/vpn/:ro" \
    -e OPENVPN_CONFIG=australia.conf \
    -e LOCAL_NETWORK=192.168.88.0/24,10.13.37.0/24 \
    -e SOCKS_USERNAME=test \
    -e SOCKS_PASSWORD=123 \
    -e SOCKS_AUTH_ONCE=0 \
    socksmyvpn:latest \
```

`curl -x socks5h://test:123@127.0.0.1:1080 https://ipinfo.io`

## Options

You can set the following environment variables. Default values below.

* `SOCKS_USERNAME=`
* `SOCKS_PASSWORD=`
* `SOCKS_AUTH_ONCE=0`
    * set to `1` to enable
* `LOCAL_NETWORK=`
    * comma separated value
* `OPENVPN_CONFIG=*.conf`

## OpenVPN Config

### Reading configuration

To pass an OpenVPN config, point a volume to `/vpn` on the container, where the
volume contains OpenVPN configs (.ovpn or .cfg).

The client by default will select the first `.conf` file it finds. You can
choose a OpenVPN config by using the `OPENVPN_CONFIG` environment variable.

e.g.
```bash
    --volume "LOCAL_FOLDER:/vpn/:ro" \
    -e OPENVPN_CONFIG=australia.ovpn
```

### Authentication

You may have issues with authentication, consider adding `auth-user-pass` to
your OpenVPN file to read credentials from a file

`auth-user-pass login.txt`

where `login.txt` is in the `/vpn` volume and contains your username and
password new-line separated

```
username
password
```

See: <https://openvpn.net/community-resources/reference-manual-for-openvpn-2-4>
for more information

## See also

* For advanced usage, consider using
[proxychains](https://github.com/rofl0r/proxychains-ng) alongside
