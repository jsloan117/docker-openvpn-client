---
hide:
  - navigation
  # - toc
---

Wireguard is provided as an alternative VPN implementation to OpenVPN. This should work out of the box on any system, except Synology which ***may*** require additional setup.

!!! info
    For more information on how to configure Synology for Wireguard, Google and the below link are you're friends.
    https://www.blackvoid.club/wireguard-spk-for-your-synology-nas

At this time one interface can be started which is `wg0`. This means you should mount your config as such.

To successfully run wireguard the following requirements are necessary

| Variable                           | Function                  | Example                                  |
| ---------------------------------- | ------------------------- | ---------------------------------------- |
| `VPN_CLIENT`                       | configures the VPN client | `VPN_CLIENT=wireguard`                   |
| `net.ipv4.conf.all.src_valid_mark` | sysctl parameter          | `1`                                      |
| `your config file`                 | your configuration file   | `path/to/config:/etc/wireguard/wg0.conf` |  |

* set variables VPN_CLIENT to `wireguard`
* set sysctl parameter `net.ipv4.conf.all.src_valid_mark` to `1`
* pass a config file like `path/to/config:/etc/wireguard/wg0.conf`

```bash
docker run --cap-add=NET_ADMIN -d --name wg_client \
-e "VPN_CLIENT=wireguard" \
--sysctl net.ipv4.conf.all.src_valid_mark=1 \
-v ~/wg0.conf:/etc/wireguard/wg0.conf \
-v /etc/localtime:/etc/localtime:ro \
jsloan117/docker-openvpn-client
```

