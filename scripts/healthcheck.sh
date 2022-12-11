#!/bin/bash

# Network check
# Ping uses both exit codes 1 and 2. Exit code 2 cannot be used for docker health checks,
# therefore we use this script to catch error code 2
HOST="${HEALTH_CHECK_HOST:=yahoo.com}"

# check DNS resolution works
if ! nslookup "$HOST" > /dev/null; then
  echo "DNS resolution failed"
  exit 1
fi

if [[ "${VPN_SOLUTION}" == "openvpn" ]]; then
  iface='tun0'
  if ! pgrep openvpn; then
    echo "Openvpn process not running"
    exit 1
  fi
elif [[ "${VPN_SOLUTION}" == "wireguard" ]]; then
  iface='wg0'
  if ! wg status wg0; then
    echo "Wireguard interface wg0 is down"
    exit 1
  fi
fi

# get at least 2 responses and timeout after 10 seconds
if ! ping -I "$iface" -c 2 -w 10 "$HOST" &> /dev/null; then
  echo "Network is down"
  # may be useful in the future to restart openvpn service
  #/command/s6-svc -r /run/service/openvpn
  exit 1
fi

exit 0

