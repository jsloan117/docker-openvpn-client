---
hide:
  - navigation
  # - toc
---

<h1 align="center">
  OpenVPN Client
</h1>

<p align="center">
  Container image that provides multiple VPN providers for OpenVPN
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

Below is a quick method to get this up and running. Please see [Running the image](run-image.md) for more details.

```bash
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
-e OPENVPN_PROVIDER='vyprvpn' \
-e OPENVPN_CONFIG='USA - Austin-256' \
-e OPENVPN_USERNAME='user' \
-e OPENVPN_PASSWORD='password' \
--dns 1.1.1.1 --dns 1.0.0.1 \
jsloan117/docker-openvpn-client
```

## Credit

---

Thank you [Haugene](https://github.com/haugene) and all contributors for making a great image.

If you need anymore [details](https://haugene.github.io/docker-transmission-openvpn) this image is based on [this](https://github.com/haugene/docker-transmission-openvpn) and their documentation may be beneficial depending on your environment.
