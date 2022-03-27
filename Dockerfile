FROM alpine:3.15

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-x86_64.tar.xz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN echo "*** installing packages ***" \
    apk upgrade --update \
    && apk --no-cache add bash openvpn curl iputils unzip jq shadow ufw \
    && wget -q -O- ${S6_OVERLAY_RELEASE} | tar -Jx -C / \
    && echo "*** cleanup ***" \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/lib/apk/* \
    && useradd -u 911 -U -d /etc/openvpn -s /sbin/nologin abc \
    && groupmod -g 911 abc \
    && apk del shadow

COPY etc /etc
COPY openvpn /etc/openvpn
COPY scripts /etc/scripts

ENV OPENVPN_PROVIDER= \
    OPENVPN_OPTS="--user abc --group abc --auth-nocache --inactive 3600 --ping 10 \
    --ping-exit 60 --resolv-retry 15 --mute-replay-warnings" \
    OPENVPN_CONFIG= \
    LOCAL_NETWORK=192.168.0.0/16 \
    CREATE_TUN_DEVICE=true \
    ENABLE_UFW=false \
    UFW_ALLOW_GW_NET=false \
    UFW_EXTRA_PORTS= \
    HEALTH_CHECK_HOST=google.com

HEALTHCHECK --interval=1m CMD /etc/scripts/healthcheck.sh

ARG REVISION
ENV REVISION=${REVISION:-""}

ARG VERSION
ENV VERSION=${VERSION:-""}

LABEL org.opencontainers.image.title="Docker OpenVPN Client"
LABEL org.opencontainers.image.description="OpenVPN Client with configs"
LABEL org.opencontainers.image.source="https://github.com/jsloan117/docker-openvpn-client"
LABEL org.opencontainers.image.documentation="http://jsloan117.github.io/docker-openvpn-client"
LABEL org.opencontainers.image.revision="$REVISION"
LABEL org.opencontainers.image.version version="$VERSION"

# Compatability with https://hub.docker.com/r/willfarrell/autoheal/
LABEL autoheal=true

VOLUME /etc/openvpn
ENTRYPOINT [ "/init" ]
