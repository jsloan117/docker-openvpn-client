The image is available from the Docker registry and this is the simplest way to get it.

To run the image use one of the following commands:

```bash
docker run --cap-add=NET_ADMIN -d --name openvpn_client \
--env-file /dockerenvironmentfile/path/DockerEnv \
-p 1194:1194 --dns 1.1.1.1 --dns 1.0.0.1 \
jsloan117/docker-openvpn-client
```

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

You must set the environment variables `OPENVPN_PROVIDER`, `OPENVPN_USERNAME` and `OPENVPN_PASSWORD` to provide basic connection details.

The `OPENVPN_CONFIG` is an optional variable. If no config is given, a default config will be selected for the provider you have chosen.
Find available OpenVPN configurations by looking in the openvpn folder of the GitHub repository. The value that you should use here is the filename of your chosen openvpn configuration _without_ the .ovpn file extension. For example:

```
-e "OPENVPN_CONFIG=USA - Austin-256"
```

You can also provide a comma separated list of openvpn configuration filenames.
If you provide a list, a file will be randomly chosen in the list, this is useful for redundancy setups. For example:

```
-e "OPENVPN_CONFIG=ipvanish-AT-Vienna-vie-c02,ipvanish-FR-Paris-par-a01,ipvanish-DE-Frankfurt-fra-a01"
```

If you provide a list and the selected server goes down, after the value of ping-timeout the container will be restarted and a server will be randomly chosen, note that the faulty server can be chosen again, if this should occur, the container will be restarted again until a working server is selected.

To make sure this work in all cases, you should add `--pull-filter ignore ping` to your OPENVPN_OPTS variable.
