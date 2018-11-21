FROM ubuntu:18.04
LABEL Name=docker-openvpn-client Version=0.1.4
LABEL maintainer="Jonathan Sloan"

RUN echo "*** updating system ***" \
    && apt-get update && apt-get -y upgrade \
    && echo "*** installing packages ***" \
    && apt-get -y install wget iputils-ping iproute2 openvpn jq \
    && wget https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64.deb \
    && dpkg -i dumb-init_1.2.2_amd64.deb \
    && rm -rf dumb-init_1.2.2_amd64.deb \
    && echo "*** cleanup ***" \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY openvpn/ /etc/openvpn/

ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    OPENVPN_OPTS= \
    LOCAL_NETWORK=192.168.0.0/16

VOLUME /etc/openvpn
CMD ["dumb-init", "/etc/openvpn/start.sh"]
