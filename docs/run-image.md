---
hide:
  - navigation
  # - toc
---

This image is available from Docker's and GitHub's registries and this is the simplest way to get it.

!!! note
    You must set at least the `OPENVPN_PROVIDER` variable, and provide your VPN credentials for this image to work.

Please see [configuration](configuration.md) for more details on each variable.

## Running the image

---

To run the image use one of (or combination of) the below methods.

### Docker run with env-file

This method is a little cleaner since your variables are stored in a file verses passed at the cli.
The [openvpn.env](https://github.com/jsloan117/docker-openvpn-client/blob/main/openvpn.env) file is an example of this.

```bash
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
--env-file ~/openvpn.env \
-v /etc/localtime:/etc/localtime:ro \
jsloan117/docker-openvpn-client
```

### Docker run without env-file

```bash
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
-e OPENVPN_PROVIDER='vyprvpn' \
-e OPENVPN_CONFIG='USA - Austin-256' \
-e OPENVPN_USERNAME='user' \
-e OPENVPN_PASSWORD='password' \
-v /etc/localtime:/etc/localtime:ro \
jsloan117/docker-openvpn-client
```

### Docker run all variables

This example shows all variables you're able to use to modify the behavior of the image.

```bash
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

### Docker compose

See the [docker-compose.yml](https://github.com/jsloan117/docker-openvpn-client/blob/main/docker-compose.yml) in this repo for an example.

## Docker secrets

---

You can use docker secrets with docker compose or docker swarm. The below steps assumes you're using docker compose.

!!! note
    Docker secrets within the context of compose inherits the file's ownership and permissions from the host.

- remove `OPENVPN_USERNAME` and `OPENVPN_PASSWORD` from the environment section of your compose file
- add your credentials username and password each on a line in a file named `vpncreds`
    - ensure correct ownership and permissions of that file `vpncreds`
- add the below snippet to your compose file

### Compose file snippet

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

