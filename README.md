# docker-openvpn-client

Docker OpenVPN Client

![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![https://microbadger.com/images/jsloan117/docker-openvpn-client](https://images.microbadger.com/badges/image/jsloan117/docker-openvpn-client.svg)
![https://microbadger.com/images/jsloan117/docker-openvpn-client](https://images.microbadger.com/badges/version/jsloan117/docker-openvpn-client.svg)
[![Codefresh build status]( https://g.codefresh.io/api/badges/pipeline/jsloan117_marketplace/jsloan117%2Fdocker-openvpn-client%2Fdocker-openvpn-client?type=cf-1)]( https://g.codefresh.io/public/accounts/jsloan117_marketplace/pipelines/jsloan117/docker-openvpn-client/docker-openvpn-client)

Docker container that provides muitiple VPN providers for OpenVPN.

VPN providers taken from Haugene's container <https://github.com/haugene/docker-transmission-openvpn>. Thank you haugene for making a great container.

## Run container from Docker registry

The container is available from the Docker registry and this is the simplest way to get it.
To run the container use this command:

```bash
$ docker run --cap-add=NET_ADMIN --device=/dev/net/tun -d --name openvpn_client \
-v /etc/localtime:/etc/localtime:ro \
--env-file /dockerenvironmentfile/path/DockerEnv \
-p 1194:1194 --dns 1.1.1.1 --dns 1.0.0.1 \
jsloan117/docker-openvpn-client
```

```bash
$ docker run --cap-add=NET_ADMIN --device=/dev/net/tun -d --name openvpn_client \
-v /etc/localtime:/etc/localtime:ro \
-e OPENVPN_PROVIDER=VYPRVPN \
-e OPENVPN_CONFIG=USA\ -\ Austin-256 \
-e OPENVPN_USERNAME=user \
-e OPENVPN_PASSWORD=password \
-e OPENVPN_OPTS=--auth-nocache\ --inactive\ 3600\ --ping\ 10\ --ping-exit\ 60 \
-p 1194:1194 --dns 1.1.1.1 --dns 1.0.0.1 \
jsloan117/docker-openvpn-client
```

### Supported providers

This is a list of providers that are bundled within the image. The custom provider setting can be used with any provider.

| Provider Name                | Config Value (`OPENVPN_PROVIDER`) |
|:-----------------------------|:-------------|
| Anonine | `ANONINE` |
| AnonVPN | `ANONVPN` |
| BlackVPN | `BLACKVPN` |
| BTGuard | `BTGUARD` |
| Cryptostorm | `CRYPTOSTORM` |
| Cypherpunk | `CYPHERPUNK` |
| FrootVPN | `FROOT` |
| FrostVPN | `FROSTVPN` |
| Giganews | `GIGANEWS` |
| HideMe | `HIDEME` |
| HideMyAss | `HIDEMYASS` |
| IntegrityVPN | `INTEGRITYVPN` |
| IPredator | `IPREDATOR` |
| IPVanish | `IPVANISH` |
| IronSocket | `IRONSOCKET` |
| Ivacy | `IVACY` |
| IVPN | `IVPN` |
| Mullvad | `MULLVAD` |
| Newshosting | `NEWSHOSTING` |
| NordVPN | `NORDVPN` |
| OVPN | `OVPN` |
| Perfect Privacy | `PERFECTPRIVACY` |
| Private Internet Access | `PIA` |
| PrivateVPN | `PRIVATEVPN` |
| proXPN | `PROXPN` |
| proxy.sh | `PROXYSH` |
| PureVPN | `PUREVPN` |
| RA4W VPN | `RA4W` |
| SaferVPN | `SAFERVPN` |
| SlickVPN | `SLICKVPN` |
| Smart DNS Proxy | `SMARTDNSPROXY` |
| SmartVPN | `SMARTVPN` |
| TigerVPN | `TIGER` |
| TorGuard | `TORGUARD` |
| TunnelBear | `TUNNELBEAR`|
| UsenetServerVPN | `USENETSERVER` |
| Windscribe | `WINDSCRIBE` |
| VPNArea.com | `VPNAREA` |
| VPN.AC | `VPNAC` |
| VPN.ht | `VPNHT` |
| VPNBook.com | `VPNBOOK` |
| VPNTunnel | `VPNTUNNEL` |
| VyprVpn | `VYPRVPN` |
| Windscribe | `WINDSCRIBE` |

### Required environment options

| Variable | Function | Example |
|----------|----------|-------|
| `OPENVPN_PROVIDER` | VPN provider | `OPENVPN_PROVIDER=VYPRVPN` |
| `OPENVPN_USERNAME` | VPN username | `OPENVPN_USERNAME=user` |
| `OPENVPN_PASSWORD` | VPN password | `OPENVPN_PASSWORD=password` |

### Network configuration options

| Variable | Function | Example |
|----------|----------|-------|
| `OPENVPN_CONFIG` | VPN endpoint to use | `OPENVPN_CONFIG=USA - Austin-256` |
| `OPENVPN_OPTS` | OpenVPN startup options | See [OpenVPN doc](https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html) |
| `LOCAL_NETWORK` | Sets the local network that should have access. Accepts comma separated list. | `LOCAL_NETWORK=192.168.0.0/24`|
