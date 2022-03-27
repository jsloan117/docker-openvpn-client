## Required variables

`OPENVPN_PROVIDER` is the only required variable, all others below are optional.

| Variable           | Function     | Example                    |
| ------------------ | ------------ | -------------------------- |
| `OPENVPN_PROVIDER` | VPN provider | `OPENVPN_PROVIDER=VYPRVPN` |

## Credentials

OpenVPN's username and password can be passed in as a config file via a mount point, docker secrets or environment variables.

| Variable           | Function     | Example                     |
| ------------------ | ------------ | --------------------------- |
| `OPENVPN_USERNAME` | VPN username | `OPENVPN_USERNAME=user`     |
| `OPENVPN_PASSWORD` | VPN password | `OPENVPN_PASSWORD=password` |

## Network configuration

The `OPENVPN_CONFIG` variable is optional to set, but is good practice. If no config is given, a default config will be selected for the provider you have chosen.

Find available OpenVPN configs by looking in the openvpn folder of the [vpn-configs-contrib repository](https://github.com/haugene/vpn-configs-contrib), or by checking your providers site.

The value that you should use here is the filename of your chosen openvpn configuration _without_ the .ovpn file extension.

For example:

```
-e "OPENVPN_CONFIG=USA - Austin-256"
```

| Variable            | Function                                                                      | Example                                                                                      |
| ------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `OPENVPN_CONFIG`    | VPN endpoint to use                                                           | `OPENVPN_CONFIG=USA - Austin-256`                                                            |
| `OPENVPN_OPTS`      | OpenVPN startup options                                                       | See [OpenVPN doc](https://openvpn.net/community-resources/reference-manual-for-openvpn-2-4/) |
| `LOCAL_NETWORK`     | Sets the local network that should have access. Accepts comma separated list. | `LOCAL_NETWORK=192.168.0.0/24`                                                               |
| `CREATE_TUN_DEVICE` | Creates /dev/net/tun device inside the container                              | `CREATE_TUN_DEVICE=true`                                                                     |

## Firewall configuration

| Variable           | Function                                                                                   | Example                          |
| ------------------ | ------------------------------------------------------------------------------------------ | -------------------------------- |
| `ENABLE_UFW`       | Enables ufw firewall                                                                       | `ENABLE_UFW=true`                |
| `UFW_ALLOW_GW_NET` | Allows the gateway network through the firewall. Off defaults to only allowing the gateway | `UFW_ALLOW_GW_NET=true`          |
| `UFW_EXTRA_PORTS`  | Allows the comma separated list of ports through the firewall. Respects UFW_ALLOW_GW_NET   | `UFW_EXTRA_PORTS=9910,23561,443` |

## Health check

Because your VPN connection can sometimes fail, Docker will run a health check on this container every minute to see if the container is still connected to the internet.

By default, this check is done by pinging google.com twice. You can change the host that is pinged.

| Variable            | Function                                                           | Example      |
| ------------------- | ------------------------------------------------------------------ | ------------ |
| `HEALTH_CHECK_HOST` | this host is pinged to check if the network connection still works | `google.com` |

## Custom scripts

If you ever need to run custom code before or after openvpn is executed you can create another file under `/etc/cont-init.d`.

You will want to make sure to use any number other than 20, since that's used for the main init-script of openvpn.

Custom scripts are located in `/etc/cont-init.d` and/or `/etc/cont-finish.d` directories, depending on what you're trying to do.

There is a newer feature "s6-rc services" as well that would serve the same or similar purpose.

For more details checkout the s6-overlay [readme](https://github.com/just-containers/s6-overlay/blob/master/README.md#init-stages).
