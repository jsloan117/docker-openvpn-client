#!/bin/bash

# Network check
# Ping uses both exit codes 1 and 2. Exit code 2 cannot be used for docker health checks,
# therefore we use this script to catch error code 2
HOST=${HEALTH_CHECK_HOST}

if [[ -z "$HOST" ]]; then
  echo "Host not set! Set env 'HEALTH_CHECK_HOST'. For now, using default google.com"
  HOST="google.com"
fi

# check DNS resolution works
if ! nslookup "$HOST" > /dev/null; then
  echo "DNS resolution failed"
  exit 1
fi

# get at least 2 responses and timeout after 10 seconds
if ! ping -I tun0 -c 2 -w 10 "$HOST" &> /dev/null; then
  echo "Network is down"
  exit 1
fi

echo "Network is up"

# service check
if ! pgrep openvpn; then
  echo "Openvpn process not running"
  exit 1
fi

echo "Openvpn process is running"
exit 0
