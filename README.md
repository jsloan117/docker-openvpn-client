# OpenVPN Client

![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
[![Build Status](https://travis-ci.com/jsloan117/docker-openvpn-client.svg?branch=master)](https://travis-ci.com/jsloan117/docker-openvpn-client)
[![Docker Pulls](https://img.shields.io/docker/pulls/jsloan117/docker-openvpn-client.svg)](https://img.shields.io/docker/pulls/jsloan117/docker-openvpn-client.svg)

Docker image that provides multiple VPN providers for OpenVPN.

## Quickstart

Below is a quick method to get this up and running. Please see the full documentation for more options.

```bash
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
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

## Documentation

The full documentation is available [here](http://jsloan117.github.io/docker-openvpn-client). If you need anymore [details](https://haugene.github.io/docker-transmission-openvpn) this image is based on [this](https://github.com/haugene/docker-transmission-openvpn) and the documentation may be benefical depending on your environment.

## Credit

Thank you [Haugene](https://github.com/haugene) and all contributors for making a great image.
