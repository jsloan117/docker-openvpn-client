FROM ubuntu:18.04
LABEL Name=docker-openvpn-client Version=0.1.2
LABEL maintainer="Jonathan Sloan"

RUN apt-get update && apt-get -y upgrade && apt-get -y install software-properties-common sudo wget git curl && \
    echo "*** install packages ***" && \
    apt-get -y install iputils-ping iproute2 net-tools dnsutils nano openvpn && \
    wget https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64.deb && \
    dpkg -i dumb-init_1.2.2_amd64.deb && \
    rm -rf dumb-init_1.2.2_amd64.deb && \
    echo "*** cleanup ***" && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD openvpn/ /etc/openvpn/

RUN chmod +x /etc/openvpn/*.sh

ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    OPENVPN_OPTS=

VOLUME /etc/openvpn
CMD ["dumb-init", "/etc/openvpn/start.sh"]
