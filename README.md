# docker-openvpn-client

![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
[![images](https://github.com/jsloan117/docker-openvpn-client/actions/workflows/images.yml/badge.svg?branch=v3.1.2)](https://github.com/jsloan117/docker-openvpn-client/actions/workflows/images.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/jsloan117/docker-openvpn-client.svg)](https://img.shields.io/docker/pulls/jsloan117/docker-openvpn-client.svg)

The image provides OpenVPN or Wireguard as a VPN client, with OpenVPN having access to multiple providers.

## Getting started

---

Below is a quick way to get up and running with either OpenVPN or Wireguard. For more details, see the complete [documentation](http://jsloan117.github.io/docker-openvpn-client).

```bash
# OpenVPN client
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
-e OPENVPN_PROVIDER='vyprvpn' \
-e OPENVPN_CONFIG='USA - Austin-256' \
-e OPENVPN_USERNAME='user' \
-e OPENVPN_PASSWORD='password' \
-v /etc/localtime:/etc/localtime:ro \
jsloan117/docker-openvpn-client
```

```bash
# Wireguard client
docker run --cap-add=NET_ADMIN -d --name wg_client \
-e "VPN_CLIENT=wireguard" \
--sysctl net.ipv4.conf.all.src_valid_mark=1 \
-v ~/wg0.conf:/etc/wireguard/wg0.conf \
-v /etc/localtime:/etc/localtime:ro \
jsloan117/docker-openvpn-client
```

## Credit

---

Thank you [Haugene](https://github.com/haugene) and all contributors for making a great image.

I initially based the image on [docker-transmission-openvpn](https://github.com/haugene/docker-transmission-openvpn). Their [documentation](https://haugene.github.io/docker-transmission-openvpn) may benefit you depending on your environment.
