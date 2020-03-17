FROM ubuntu:18.04
LABEL Name=docker-openvpn-client Maintainer="Jonathan Sloan"

RUN echo "*** installing packages ***" \
    && apt-get update && apt-get -y --no-install-recommends install wget iputils-ping iproute2 openvpn jq tzdata dumb-init \
    && echo "*** cleanup ***" \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/lists/*

COPY openvpn /etc/openvpn
COPY scripts /etc/scripts

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
