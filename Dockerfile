FROM ubuntu:20.04
LABEL Name=docker-openvpn-client Maintainer="Jonathan Sloan"

ENV DEBIAN_FRONTEND=noninteractive LC_ALL=C.UTF-8 LANG=C.UTF-8

RUN echo "*** installing packages ***" \
    && apt-get update && apt-get -y --no-install-recommends install curl unzip iputils-ping iproute2 openvpn jq dumb-init \
    && echo "*** cleanup ***" \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/lists/*

COPY openvpn /etc/openvpn
COPY scripts /etc/scripts
COPY VERSION .

ENV OPENVPN_USERNAME="**None**" \
    OPENVPN_PASSWORD="**None**" \
    OPENVPN_PROVIDER="**None**" \
    OPENVPN_OPTS="" \
    LOCAL_NETWORK="192.168.0.0/16" \
    CREATE_TUN_DEVICE="true" \
    HEALTH_CHECK_HOST="google.com"

HEALTHCHECK --interval=5m CMD /etc/scripts/healthcheck.sh

VOLUME /etc/openvpn
CMD ["dumb-init", "/etc/openvpn/start.sh"]
