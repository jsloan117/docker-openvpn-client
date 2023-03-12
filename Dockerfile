FROM ubuntu:22.04

ARG TARGETPLATFORM
ARG S6_OVERLAY_NOARCH_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-noarch.tar.xz

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C.UTF-8 LANG=C.UTF-8

RUN echo '*** installing packages ***' \
    && apt-get update && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends openvpn curl unzip jq iputils-ping iproute2 psmisc \
       iptables bind9-dnsutils kmod ca-certificates wget xz-utils net-tools ufw openresolv wireguard-tools \
    && case ${TARGETPLATFORM} in \
            'linux/amd64')  S6_OVERLAY_ARCH=x86_64  ;; \
            'linux/arm64')  S6_OVERLAY_ARCH=aarch64  ;; \
       esac \
    && S6_OVERLAY_ARCH_RELEASE="https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz" \
    && wget -q -O- "${S6_OVERLAY_ARCH_RELEASE}" | tar -Jpx -C / \
    && wget -q -O- "${S6_OVERLAY_NOARCH_RELEASE}" | tar -Jpx -C / \
    && useradd -u 911 -U -d /etc/openvpn -s /sbin/nologin abc \
    && groupmod -g 911 abc \
    && sed -i 's|up)|up\|route-up)|; s|down)|down\|route-pre-down)|' /etc/openvpn/update-resolv-conf \
    && echo '*** wireguard wg-quick hack ***' \
    && sed -i 's/sysctl.*/sysctl -q net.ipv4.conf.all.src_valid_mark=1 || true/' /usr/bin/wg-quick \
    && echo '*** cleanup ***' \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/*

COPY etc /etc
COPY openvpn /etc/openvpn
COPY scripts /etc/scripts
COPY services /services

ENV VPN_CLIENT='openvpn' \
    OPENVPN_PROVIDER= \
    OPENVPN_OPTS='--auth-nocache --mute-replay-warnings --script-security 2 --route-up /etc/openvpn/update-resolv-conf --down /etc/openvpn/update-resolv-conf' \
    OPENVPN_CONFIG= \
    LOCAL_NETWORK='192.168.0.0/16' \
    CREATE_TUN_DEVICE='true' \
    ENABLE_UFW='false' \
    UFW_KILLSWITCH=false \
    UFW_FAILSAFE=false \
    UFW_ALLOW_GW_NET='false' \
    UFW_EXTRA_PORTS= \
    HEALTH_CHECK_HOST='google.com' \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME='60000' \
    # this should allow us to dynamically use openvpn or wireguard
    S6_STAGE2_HOOK='/etc/scripts/init.sh'

HEALTHCHECK --interval=1m CMD /etc/scripts/healthcheck.sh

LABEL org.opencontainers.image.documentation=http://jsloan117.github.io/docker-openvpn-client

# Compatability with https://hub.docker.com/r/willfarrell/autoheal/
LABEL autoheal=true

VOLUME /etc/openvpn
ENTRYPOINT [ "/init" ]
