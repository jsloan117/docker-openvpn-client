---
hide:
  - navigation
  # - toc
---

## Internal providers

---

These providers have had a script created to download configs directly from the provider on container startup automatically.

| Provider Name           | Config Value (`OPENVPN_PROVIDER`) |
| :---------------------- | :-------------------------------- |
| IPVanish                | `IPVANISH`                        |
| NordVPN                 | `NORDVPN`                         |
| Private Internet Access | `PIA`                             |
| VyprVpn                 | `VYPRVPN`                         |

## External providers

---

We fetch these providers on startup from [config repo](https://github.com/haugene/vpn-configs-contrib).
They must be manually updated in that repo when the provider changes them.

Open a [:fontawesome-solid-code-pull-request:](https://github.com/haugene/vpn-configs-contrib/pulls) if you don't see your provider in the below list or the config repo above.

| Provider Name   | Config Value (`OPENVPN_PROVIDER`) |
| :-------------- | :-------------------------------- |
| Anonine         | `ANONINE`                         |
| AnonVPN         | `ANONVPN`                         |
| BlackVPN        | `BLACKVPN`                        |
| BTGuard         | `BTGUARD`                         |
| Cryptostorm     | `CRYPTOSTORM`                     |
| ExpressVPN      | `EXPRESSVPN`                      |
| FastestVPN      | `FASTESTVPN`                      |
| FreeVPN         | `FREEVPN`                         |
| FrootVPN        | `FROOT`                           |
| FrostVPN        | `FROSTVPN`                        |
| Getflix         | `GETFLIX`                         |
| GhostPath       | `GHOSTPATH`                       |
| Giganews        | `GIGANEWS`                        |
| HideMe          | `HIDEME`                          |
| HideMyAss       | `HIDEMYASS`                       |
| IntegrityVPN    | `INTEGRITYVPN`                    |
| IronSocket      | `IRONSOCKET`                      |
| Ivacy           | `IVACY`                           |
| IVPN            | `IVPN`                            |
| Mullvad         | `MULLVAD`                         |
| OctaneVPN       | `OCTANEVPN`                       |
| OVPN            | `OVPN`                            |
| Privado         | `PRIVADO`                         |
| PrivateVPN      | `PRIVATEVPN`                      |
| ProtonVPN       | `PROTONVPN`                       |
| proXPN          | `PROXPN`                          |
| PureVPN         | `PUREVPN`                         |
| RA4W VPN        | `RA4W`                            |
| SaferVPN        | `SAFERVPN`                        |
| SlickVPN        | `SLICKVPN`                        |
| Smart DNS Proxy | `SMARTDNSPROXY`                   |
| SmartVPN        | `SMARTVPN`                        |
| Surfshark       | `SURFSHARK`                       |
| TigerVPN        | `TIGER`                           |
| TorGuard        | `TORGUARD`                        |
| Trust.Zone      | `TRUSTZONE`                       |
| TunnelBear      | `TUNNELBEAR`                      |
| VPNArea.com     | `VPNAREA`                         |
| VPNBook.com     | `VPNBOOK`                         |
| VPNFacile       | `VPNFACILE`                       |
| VPNTunnel       | `VPNTUNNEL`                       |
| VPNUnlimited    | `VPNUNLIMITED`                    |
| VPN.AC          | `VPNAC`                           |
| VPN.ht          | `VPNHT`                           |
| Windscribe      | `WINDSCRIBE`                      |
| ZoogVPN         | `ZOOGVPN`                         |

