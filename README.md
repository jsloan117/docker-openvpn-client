# docker-openvpn-client

Docker OpenVPN Client

![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/jsloan117/docker-openvpn-client.svg)
![Docker Build Status](https://img.shields.io/docker/cloud/build/jsloan117/docker-openvpn-client.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/jsloan117/docker-openvpn-client.svg)
[![](https://images.microbadger.com/badges/image/jsloan117/docker-openvpn-client.svg)](https://microbadger.com/images/jsloan117/docker-openvpn-client "Get your own image badge on microbadger.com")

Docker container that provides muitiple VPN providers for OpenVPN.

VPN providers taken from Haugene's container <https://github.com/haugene/docker-transmission-openvpn>. Thank you haugene for making a great container.

## Run container from Docker registry

The container is available from the Docker registry and this is the simplest way to get it.
To run the container use this command:

```bash
$ docker run --cap-add=NET_ADMIN -d --name openvpn_client \
-v /etc/localtime:/etc/localtime:ro \
--env-file /dockerenvironmentfile/path/DockerEnv \
-p 1194:1194 --dns 1.1.1.1 --dns 1.0.0.1 \
jsloan117/docker-openvpn-client
```

```bash
$ docker run --cap-add=NET_ADMIN -d --name openvpn_client \
-v /etc/localtime:/etc/localtime:ro \
-e CREATE_TUN_DEVICE=true \
-e OPENVPN_PROVIDER=VYPRVPN \
-e OPENVPN_CONFIG=USA\ -\ Austin-256 \
-e OPENVPN_USERNAME=user \
-e OPENVPN_PASSWORD=password \
-e OPENVPN_OPTS=--auth-nocache\ --inactive\ 3600\ --ping\ 10\ --ping-exit\ 60 \
-e LOCAL_NETWORK=192.168.0.0/16 \
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
| FastestVPN | `FASTESTVPN` |
| FreeVPN | `FREEVPN` |
| FrootVPN | `FROOT` |
| FrostVPN | `FROSTVPN` |
| Ghostpath | `GHOSTPATH` |
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
| ProtonVPN | `PROTONVPN` |
| proXPN | `PROXPN` |
| proxy.sh | `PROXYSH` |
| PureVPN | `PUREVPN` |
| RA4W VPN | `RA4W` |
| SaferVPN | `SAFERVPN` |
| SlickVPN | `SLICKVPN` |
| Smart DNS Proxy | `SMARTDNSPROXY` |
| SmartVPN | `SMARTVPN` |
| Surfshark | `SURFSHARK` |
| TigerVPN | `TIGER` |
| TorGuard | `TORGUARD` |
| TunnelBear | `TUNNELBEAR`|
| UsenetServerVPN | `USENETSERVER` |
| Windscribe | `WINDSCRIBE` |
| VPNArea.com | `VPNAREA` |
| VPN.AC | `VPNAC` |
| VPN.ht | `VPNHT` |
| VPNBook.com | `VPNBOOK` |
| VPNFacile | `VPNFACILE` |
| VPNTunnel | `VPNTUNNEL` |
| VPNUnlimited | `VPNUNLIMITED` |
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
| `LOCAL_NETWORK` | Sets the local network that should have access. Accepts comma separated list. | `LOCAL_NETWORK=192.168.0.0/24` |
| `CREATE_TUN_DEVICE` | Creates /dev/net/tun device inside the container, mitigates the need to mount the device from the host | `CREATE_TUN_DEVICE=true` |

### Health check option

Because your VPN connection can sometimes fail, Docker will run a health check on this container every 5 minutes to see if the container is still connected to the internet. By default, this check is done by pinging google.com once. You can change the host that is pinged.

| Variable | Function | Example |
|----------|----------|-------|
| `HEALTH_CHECK_HOST` | this host is pinged to check if the network connection still works | `google.com` |

### Custom pre/post scripts

If you ever need to run custom code before openvpn is executed you can use the custom scripts feature.
Custom scripts are located in the /scripts directory.
To enable this feature, you'll need to mount the /scripts directory.

| Script | Function |
|----------|----------|
| `/scripts/openvpn-pre-start.sh` | This shell script will be executed before openvpn start |
