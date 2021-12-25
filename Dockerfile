FROM alpine:3.15

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN echo "*** installing packages ***" \
    apk upgrade --update \
    && apk --no-cache add bash openvpn curl iputils unzip jq shadow \
    && wget -q -O- ${S6_OVERLAY_RELEASE} | tar -zx -C / \
    && echo "*** cleanup ***" \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/lib/apk/* \
    && useradd -u 911 -U -d /etc/openvpn -s /bin/false abc

COPY etc /etc
COPY openvpn /etc/openvpn
COPY scripts /etc/scripts
COPY VERSION /

ENV OPENVPN_USERNAME="" \
    OPENVPN_PASSWORD="" \
    OPENVPN_PROVIDER="" \
    OPENVPN_OPTS="" \
    OPENVPN_CONFIG="" \
    LOCAL_NETWORK="192.168.0.0/16" \
    CREATE_TUN_DEVICE="true" \
    HEALTH_CHECK_HOST="google.com"

HEALTHCHECK --interval=5m CMD /etc/scripts/healthcheck.sh

ARG REVISION
ENV REVISION=${REVISION:-""}

LABEL org.opencontainers.image.name=docker-openvpn-client
LABEL org.opencontainers.image.source=https://github.com/jsloan117/docker-openvpn-client
LABEL org.opencontainers.image.documentation=http://jsloan117.github.io/docker-openvpn-client
LABEL org.opencontainers.image.revision=$REVISION

VOLUME /etc/openvpn
ENTRYPOINT [ "/init" ]
