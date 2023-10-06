---
hide:
  - navigation
  # - toc
---

<h1 align="center">
  OpenVPN or Wireguard client
</h1>

<p align="center">
  The image provides OpenVPN or Wireguard as a VPN client, with OpenVPN having access to multiple providers.
  <br><br>

  <a href="https://github.com/jsloan117/docker-deluge/blob/master/LICENSE">
    <img alt="license" src="https://img.shields.io/badge/License-GPLv3-blue.svg" />
  </a>
  <a href="https://github.com/jsloan117/docker-openvpn-client/actions/workflows/images.yml">
    <img alt="images" src="https://github.com/jsloan117/docker-openvpn-client/actions/workflows/images.yml/badge.svg?branch=v3.1.2" />
  </a>
  <a href="https://hub.docker.com/repository/docker/jsloan117/docker-openvpn-client">
    <img alt="pulls" src="https://img.shields.io/docker/pulls/jsloan117/docker-openvpn-client.svg" />
  </a>
</p>

## Getting started

---

Below is a quick way to get up and running with either OpenVPN or Wireguard. For more details, see [running the image](run-image.md).

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

