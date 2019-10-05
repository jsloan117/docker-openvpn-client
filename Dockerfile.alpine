FROM alpine:latest
LABEL Name=docker-openvpn-client Version=0.4.0
LABEL maintainer="Jonathan Sloan"

RUN echo "*** updating system ***" \
    && apk update && apk upgrade \
    && echo "*** installing packages ***" \
    && apk --no-cache add bash dumb-init openvpn shadow curl jq tzdata \
    && echo "*** cleanup ***" \
    && rm -rf /tmp/* /var/tmp/*

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
