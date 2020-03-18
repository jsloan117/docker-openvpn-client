<h1 align="center">
  OpenVPN Client
</h1>

<p align="center">
  Docker image that provides multiple VPN providers for OpenVPN
  <br><br>

  <a href="https://github.com/jsloan117/docker-deluge/blob/master/LICENSE">
    <img alt="license" src="https://img.shields.io/badge/License-GPLv3-blue.svg" />
  </a>
  <a href="https://travis-ci.com/jsloan117/docker-openvpn-client">
    <img alt="build" src="https://travis-ci.com/jsloan117/docker-openvpn-client.svg?branch=master" />
  </a>
  <a href="https://hub.docker.com/repository/docker/jsloan117/docker-openvpn-client">
    <img alt="pulls" src="https://img.shields.io/docker/pulls/jsloan117/docker-openvpn-client.svg" />
  </a>
</p>

## Quickstart

Below is a quick method to get this up and running. Please see [Run from Docker registry](http://jsloan117.github.io/docker-openvpn-client/run-from-docker-registry) for more details and commands.

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

## Credit

Thank you [Haugene](https://github.com/haugene) and all contributors for making a great image.

If you need anymore [details](https://haugene.github.io/docker-transmission-openvpn) this image is based on [this](https://github.com/haugene/docker-transmission-openvpn) and the documentation may be benefical depending on your environment.
