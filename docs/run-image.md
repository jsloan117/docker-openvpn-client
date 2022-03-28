This image is available from Docker's and GitHub's registries and this is the simplest way to get it.

You must set the variable `OPENVPN_PROVIDER`, and provide your VPN credentials for this image to work.

Please see [configuration](configuration.md) for more details on each variable.

## Running the image

To run the image use one of the following:

### Docker run with env-file

This method is a little cleaner since your variables are stored in a file verses passed at the cli.
The [openvpn.env](https://github.com/jsloan117/docker-openvpn-client/blob/main/openvpn.env) file is an example of this.

```bash
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
--env-file ~/openvpn.env \
--dns 1.1.1.1 --dns 1.0.0.1 \
jsloan117/docker-openvpn-client
```

### Docker run without env-file

```bash
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
-e OPENVPN_PROVIDER='vyprvpn' \
-e OPENVPN_CONFIG='USA - Austin-256' \
-e OPENVPN_USERNAME='user' \
-e OPENVPN_PASSWORD='password' \
--dns 1.1.1.1 --dns 1.0.0.1 \
jsloan117/docker-openvpn-client
```

### Docker run all variables

This example shows all variables you're able to use to modify the behavior of the image.

```bash
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
-e OPENVPN_USERNAME='user' \
-e OPENVPN_PASSWORD='password' \
-e OPENVPN_PROVIDER='vyprvpn' \
-e OPENVPN_OPTS='--user abc --group abc --auth-nocache --inactive 3600 --ping 10 --ping-exit 60' \
-e OPENVPN_CONFIG='USA - Austin-256' \
-e LOCAL_NETWORK='192.168.0.0/16' \
-e CREATE_TUN_DEVICE='true' \
-e ENABLE_UFW='true' \
-e UFW_ALLOW_GW_NET='true' \
-e UFW_EXTRA_PORTS='8080,9091' \
-e HEALTH_CHECK_HOST='google.com' \
--dns 1.1.1.1 --dns 1.0.0.1 \
jsloan117/docker-openvpn-client
```

### Docker compose

See the [docker-compose.yml](https://github.com/jsloan117/docker-openvpn-client/blob/main/docker-compose.yml) in this repo for an example.

## Docker secrets

You can use docker secrets in a compose file or docker swarm mode. The below steps assumes you're using a compose file.

- remove `OPENVPN_USERNAME` and `OPENVPN_PASSWORD` from the environment section of your compose file
- add your credentials username and password each on a line in a file named `vpncreds`
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
