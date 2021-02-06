## Required environment options

| Variable           | Function     | Example                     |
| ------------------ | ------------ | --------------------------- |
| `OPENVPN_PROVIDER` | VPN provider | `OPENVPN_PROVIDER=VYPRVPN`  |
| `OPENVPN_USERNAME` | VPN username | `OPENVPN_USERNAME=user`     |
| `OPENVPN_PASSWORD` | VPN password | `OPENVPN_PASSWORD=password` |

## Network configuration options

| Variable            | Function                                                                      | Example                                                                                      |
| ------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `OPENVPN_CONFIG`    | VPN endpoint to use                                                           | `OPENVPN_CONFIG=USA - Austin-256`                                                            |
| `OPENVPN_OPTS`      | OpenVPN startup options                                                       | See [OpenVPN doc](https://openvpn.net/community-resources/reference-manual-for-openvpn-2-4/) |
| `LOCAL_NETWORK`     | Sets the local network that should have access. Accepts comma separated list. | `LOCAL_NETWORK=192.168.0.0/24`                                                               |
| `CREATE_TUN_DEVICE` | Creates /dev/net/tun device inside the container                              | `CREATE_TUN_DEVICE=true`                                                                     |

## Health check option

Because your VPN connection can sometimes fail, Docker will run a health check on this container every 5 minutes to see if the container is still connected to the internet. By default, this check is done by pinging google.com twice. You can change the host that is pinged.

| Variable            | Function                                                           | Example      |
| ------------------- | ------------------------------------------------------------------ | ------------ |
| `HEALTH_CHECK_HOST` | this host is pinged to check if the network connection still works | `google.com` |

## Custom pre/post scripts

If you ever need to run custom code before openvpn is executed you can use the custom scripts feature.
Custom scripts are located in the /scripts directory.
To enable this feature, you'll need to mount the /scripts directory.

| Script                          | Function                                                |
| ------------------------------- | ------------------------------------------------------- |
| `/scripts/openvpn-pre-start.sh` | This shell script will be executed before openvpn start |
