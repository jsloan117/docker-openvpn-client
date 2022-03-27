# OpenVPN Client

![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
[![images](https://github.com/jsloan117/docker-openvpn-client/actions/workflows/images.yml/badge.svg)](https://github.com/jsloan117/docker-openvpn-client/actions/workflows/images.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/jsloan117/docker-openvpn-client.svg)](https://img.shields.io/docker/pulls/jsloan117/docker-openvpn-client.svg)

Docker image that provides multiple VPN providers for OpenVPN.

## Quickstart

Below is a quick method to get this up and running. Please see the full documentation for more options.

```bash
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
-e OPENVPN_PROVIDER='vyprvpn' \
-e OPENVPN_CONFIG='USA - Austin-256' \
-e OPENVPN_USERNAME='user' \
-e OPENVPN_PASSWORD='password' \
--dns 1.1.1.1 --dns 1.0.0.1 \
jsloan117/docker-openvpn-client
```

## Documentation

The full documentation is available [here](http://jsloan117.github.io/docker-openvpn-client). If you need anymore [details](https://haugene.github.io/docker-transmission-openvpn) this image is based on [this](https://github.com/haugene/docker-transmission-openvpn) and their documentation may be beneficial depending on your environment.

## Credit

Thank you [Haugene](https://github.com/haugene) and all contributors for making a great image.
