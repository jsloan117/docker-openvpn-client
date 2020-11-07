FROM alpine:3.12

RUN echo "*** installing packages ***" \
    && apk update && apk --no-cache add bash dumb-init openvpn curl iputils unzip jq \
    && echo "*** cleanup ***" \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/lib/apk/*

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

# Add labels to identify this image and version
ARG REVISION
# Set env from build argument or default to empty string
ENV REVISION=${REVISION:-""}

LABEL org.opencontainers.image.name=docker-openvpn-client
LABEL org.opencontainers.image.source=https://github.com/jsloan117/docker-openvpn-client
LABEL org.opencontainers.image.revision=$REVISION

VOLUME /etc/openvpn
CMD ["dumb-init", "/etc/openvpn/start.sh"]
