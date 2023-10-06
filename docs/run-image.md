---
hide:
  - navigation
  # - toc
---

This image is available from Docker and GitHub registries, which is the simplest way to get it.

!!! note
    You can not run OpenVPN and Wireguard at the same time. The `VPN_CLIENT` variable allows you to choose which one.

Please see [configuration](configuration.md) for more details on all the variables in this image.

## OpenVPN

---

!!! note
    You must set at least the `OPENVPN_PROVIDER` variable and provide your VPN credentials for this image to work with OpenVPN.

### environment file

This method is cleaner since your variables are in a file versus passed at the CLI.
The [openvpn.env](https://github.com/jsloan117/docker-openvpn-client/blob/main/openvpn.env) file is an example of this.

```bash linenums="1"
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
--env-file ~/openvpn.env \
-v /etc/localtime:/etc/localtime:ro \
jsloan117/docker-openvpn-client
```

### docker cli

```bash linenums="1"
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
-e OPENVPN_PROVIDER='vyprvpn' \
-e OPENVPN_CONFIG='USA - Austin-256' \
-e OPENVPN_USERNAME='user' \
-e OPENVPN_PASSWORD='password' \
-v /etc/localtime:/etc/localtime:ro \
jsloan117/docker-openvpn-client
```

### all available variables

This example shows all variables you can use to modify the behavior of the image.

??? example "all variables"
    ```bash linenums="1"
    docker run --cap-add=NET_ADMIN -d --name openvpn_client \
    -e OPENVPN_USERNAME='user' \
    -e OPENVPN_PASSWORD='password' \
    -e OPENVPN_PROVIDER='vyprvpn' \
    -e OPENVPN_OPTS='--auth-nocache --mute-replay-warnings --script-security 2 --route-up /etc/openvpn/update-resolv-conf --down /etc/openvpn/update-resolv-conf' \
    -e OPENVPN_CONFIG='USA - Austin-256' \
    -e LOCAL_NETWORK='192.168.0.0/16' \
    -e CREATE_TUN_DEVICE='true' \
    -e ENABLE_UFW='true' \
    -e UFW_KILLSWITCH=true \
    -e UFW_FAILSAFE=true \
    -e UFW_ALLOW_GW_NET='true' \
    -e UFW_EXTRA_PORTS='8080,9091' \
    -e HEALTH_CHECK_HOST='google.com' \
    -e S6_CMD_WAIT_FOR_SERVICES_MAXTIME='60000' \
    -v /etc/localtime:/etc/localtime:ro \
    jsloan117/docker-openvpn-client
    ```

### docker compose

??? example "docker compose"
    ```bash linenums="1"
    ---
    services:
      docker-openvpn-client:
        image: jsloan117/docker-openvpn-client
        cap_add:
          - NET_ADMIN
        restart: on-failure
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - openvpn_data:/etc/openvpn
        environment:
          - VPN_CLIENT=openvpn
          - OPENVPN_USERNAME=
          - OPENVPN_PASSWORD=
          - OPENVPN_PROVIDER=
          - OPENVPN_OPTS=--auth-nocache --mute-replay-warnings --script-security 2 --route-up /etc/openvpn/update-resolv-conf --down /etc/openvpn/update-resolv-conf
          - OPENVPN_CONFIG=
          - LOCAL_NETWORK=192.168.0.0/16
          - CREATE_TUN_DEVICE=true
          - ENABLE_UFW=false
          - UFW_KILLSWITCH=false
          - UFW_FAILSAFE=false
          - UFW_ALLOW_GW_NET=false
          - UFW_EXTRA_PORTS=
          - HEALTH_CHECK_HOST=google.com
          - S6_CMD_WAIT_FOR_SERVICES_MAXTIME=60000
        healthcheck:
          test: [CMD, /etc/scripts/healthcheck.sh]
          interval: 1m

    volumes:
      openvpn_data:
    ```

### docker secrets

---

You can use docker secrets with docker compose or docker swarm. The below steps assume you're using docker compose.

!!! note
    Docker secrets within the context of docker compose inherit the file's ownership and permissions from the host.

- remove `OPENVPN_USERNAME` and `OPENVPN_PASSWORD` from the environment section of your compose file
- add your credentials, username, and password each on a line in a file named `vpncreds`
    - ensure correct ownership and permissions of that file `vpncreds`
- add the below snippet to your compose file

### compose file snippet

```yaml
version: '3.8'

services:
  docker-openvpn-client:
    ...
    secrets:
      - vpncreds

secrets:
  vpncreds:
    file: ./vpncreds
```

### vpncreds file

```bash
your_vpn_username
your_vpn_password
```

## Wireguard

---

!!! note
    You must set the variable `VPN_CLIENT` to `wireguard` and provide a config for this image to work with Wireguard.

Wireguard is an alternative VPN client to OpenVPN. It should work on any system where the kernel module is available, except Synology, which ***may*** require additional setup.

??? info "Obtaining wireguard spk for Synology"
    If you're lucky :smile: you can download an SPK from [here](https://www.blackvoid.club/wireguard-spk-for-your-synology-nas). If not, that link should help you in building your own.

You should be able to obtain a config from your VPN provider if they support it.

???+ info
    You may see the following in the logs when running wireguard.
    From my testing, this hasn't caused problems, and `src_valid_mark=1` is set correctly in the container.

    If it does, or you want to get rid of the message, you must pass [--privileged](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) as a docker run argument. Or `privileged: true` in your compose file.

    ```bash
    docker logs wg_client
    ...
    [#] sysctl -q net.ipv4.conf.all.src_valid_mark=1
    sysctl: setting key "net.ipv4.conf.all.src_valid_mark", ignoring: Read-only file system
    ...
    ```

### docker cli

??? example "docker cli"
    ```bash linenums="1"
    docker run --cap-add=NET_ADMIN -d --name wg_client \
    -e "VPN_CLIENT=wireguard" \
    --sysctl net.ipv4.conf.all.src_valid_mark=1 \
    -v ~/wg0.conf:/etc/wireguard/wg0.conf \
    -v /etc/localtime:/etc/localtime:ro \
    jsloan117/docker-openvpn-client
    ```

### docker compose

??? example "docker compose"
    ```bash linenums="1"
    ---
    services:
      docker-openvpn-client:
        image: jsloan117/docker-openvpn-client
        cap_add:
          - NET_ADMIN
        sysctls:
          - net.ipv4.conf.all.src_valid_mark=1
        restart: on-failure
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - ~/wg0.conf:/etc/wireguard/wg0.conf
        environment:
          - VPN_CLIENT=wireguard
          - HEALTH_CHECK_HOST=google.com
          - S6_CMD_WAIT_FOR_SERVICES_MAXTIME=60000
        healthcheck:
          test: [CMD, /etc/scripts/healthcheck.sh]
          interval: 1m
    ```

### misc

Adding PersistentKeepalive to your config may be beneficial. See the [man page](https://www.man7.org/linux/man-pages/man8/wg.8.html) for more details and options.

??? tip "add PersistentKeepalive to config"
    ```bash
    [Interface]
    ...

    [Peer]
    ...
    PersistentKeepalive = 25
    ```

??? example "check if src_valid_mark is enabled"
    ```bash
    cat  /proc/sys/net/ipv4/conf/all/src_valid_mark
    ```

## Additional documentation

* [docker privileged mode](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities)
* [docker security](https://docs.docker.com/engine/security/#linux-kernel-capabilities)
* [docker supported sysctls](https://docs.docker.com/engine/reference/commandline/run/#currently-supported-sysctls)
* [wireguard manpage](https://www.man7.org/linux/man-pages/man8/wg.8.html)
* [wireguard network namespace](https://www.wireguard.com/netns/) - See section under "Improved Rule-based Routing"
* [kernel ip sysctl](https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html)

