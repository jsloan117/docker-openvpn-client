FROM ubuntu:18.04
LABEL Name=docker-openvpn-client Version=0.4.0
LABEL maintainer="Jonathan Sloan"

RUN echo "*** updating system ***" \
    && apt-get update && apt-get -y upgrade \
    && echo "*** installing packages ***" \
    && apt-get -y install wget iputils-ping iproute2 openvpn jq tzdata dumb-init \
    && echo "*** cleanup ***" \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/*

ADD openvpn/ /etc/openvpn/
ADD scripts/ /etc/scripts/

ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    OPENVPN_OPTS= \
    LOCAL_NETWORK=192.168.0.0/16 \
    CREATE_TUN_DEVICE=true \
    HEALTH_CHECK_HOST=google.com

HEALTHCHECK --interval=5m CMD /etc/scripts/healthcheck.sh

VOLUME /etc/openvpn
CMD ["dumb-init", "/etc/openvpn/start.sh"]
