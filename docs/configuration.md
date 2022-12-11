---
hide:
  - navigation
  # - toc
---

## Required variables

---

`OPENVPN_PROVIDER` is the only required variable, all others below are optional.

| Variable           | Function     | Example                    |
| ------------------ | ------------ | -------------------------- |
| `OPENVPN_PROVIDER` | VPN provider | `OPENVPN_PROVIDER=VYPRVPN` |

## Credentials

---

OpenVPN's username and password can be passed in as a config file via a mount point, docker secrets or environment variables.

| Variable           | Function     | Example                     |
| ------------------ | ------------ | --------------------------- |
| `OPENVPN_USERNAME` | VPN username | `OPENVPN_USERNAME=user`     |
| `OPENVPN_PASSWORD` | VPN password | `OPENVPN_PASSWORD=password` |

## Network

---

It is strongly recommended that you keep `--route-up` and `--down` arguments of `OPENVPN_OPTS`. Running `/etc/openvpn/update-resolv-conf` helps configure DNS for the container and prevent DNS leaks.

The `OPENVPN_CONFIG` variable is optional to set, but is good practice. If no config is given, a default config will be selected for the provider you have chosen.

Find available OpenVPN configs by looking in the openvpn folder of the [vpn-configs-contrib repository](https://github.com/haugene/vpn-configs-contrib), or by checking your providers site.

The value that you should use is the filename of your chosen openvpn configuration _without_ the .ovpn file extension.

??? example "openvpn config"

    ```dockerfile
    -e "OPENVPN_CONFIG=USA - Austin-256"
    ```

| Variable            | Function                                                                      | Example                                                                     |
| ------------------- | ----------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `OPENVPN_CONFIG`    | VPN endpoint to use                                                           | `OPENVPN_CONFIG=USA - Austin-256`                                           |
| `OPENVPN_OPTS`      | OpenVPN startup options                                                       | See [OpenVPN doc](https://build.openvpn.net/man/openvpn-2.5/openvpn.8.html) |
| `LOCAL_NETWORK`     | Sets the local network that should have access. Accepts comma separated list. | `LOCAL_NETWORK=192.168.0.0/24`                                              |
| `CREATE_TUN_DEVICE` | Creates /dev/net/tun device inside the container                              | `CREATE_TUN_DEVICE=true`                                                    |

## Firewall

---

| Variable           | Function                                                                                      | Example                          |
| ------------------ | --------------------------------------------------------------------------------------------- | -------------------------------- |
| `ENABLE_UFW`       | Enables ufw firewall                                                                          | `ENABLE_UFW=true`                |
| `UFW_KILLSWITCH`   | Turns UFW into a firewall kill switch                                                         | `UFW_KILLSWITCH=true`            |
| `UFW_FAILSAFE`     | allow local network access - make sure we can always get to it ("localNet")                   | `UFW_FAILSAFE=true`              |
| `UFW_ALLOW_GW_NET` | Allows the gateway network through the firewall. False defaults to only allowing the gateway. | `UFW_ALLOW_GW_NET=true`          |
| `UFW_EXTRA_PORTS`  | Allows the comma separated list of ports through the firewall. Respects UFW_ALLOW_GW_NET.     | `UFW_EXTRA_PORTS=9910,23561,443` |

## Health check

---

Docker will run a health check on the container every minute to see if it is still connected to the Internet.

By default, this is done by pinging yahoo.com twice. You can change the host that is pinged.

| Variable            | Function                                                           | Example      |
| ------------------- | ------------------------------------------------------------------ | ------------ |
| `HEALTH_CHECK_HOST` | This host is pinged to check if the network connection still works | `google.com` |

## s6-overlay

---

If you encounter a timeout error like the below, you may need to adjust the `S6_CMD_WAIT_FOR_SERVICES_MAXTIME` value.

There are more environment variables for s6 and information on them can be found [here](https://github.com/just-containers/s6-overlay#customizing-s6-behaviour).

???+ error

    ```text
    s6-rc: fatal: timed out
    s6-sudoc: fatal: unable to get exit status from server: Operation timed out
    ```

| Variable                           | Function                                                                                                   | Example |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------- |
| `S6_CMD_WAIT_FOR_SERVICES_MAXTIME` | Global timeout value in milliseconds for all services. You can disable it by setting this variable to `0`. | `60000` |

## Custom scripts

---

If the need arises to run custom scripts before or after OpenVPN is executed, you can do so.
While this is not the only way ([s6-rc-services](s6-overlay.md#s6-rc-services)), it is probably the easiest.

Custom scripts are located in `/etc/cont-init.d` and `/etc/cont-finish.d` directories, depending on when you want them executed.

You will need to make sure your scripts are executable. Then mount your scripts directories to one of or both of the directories above.

They will automatically be executed before or after OpenVPN does sequentially. Have a look at [s6-init-stages](s6-overlay.md#init-stages) for more details.

??? example "pre-openvpn-script"

    ```bash
    # /etc/cont-init.d/05-inject-env-var-into-s6.sh
    printf '%s' "${MY_IMPORTANT_VARIABLE}" > /run/s6/container_environment/MY_IMPORTANT_VARIABLE
    ```

??? example "post-openvpn-script"
    ```bash
    # /etc/cont-finish.d/04-remove-junk.sh
    rm -f /tmp/junkfiles
    ```

