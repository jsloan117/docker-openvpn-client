#!/command/with-contenv bash
# shellcheck shell=bash

attempted to delete routes as root user when openvpn is NOT running as root

exec s6-setuidgid root /delete_routes.sh

public_ip=$(curl -s4 ifconfig.me)

if [[ -z $public_ip ]]; then
  echo "failed to obtain public IP address"
  exit 1
fi

echo "Deleting VPN routes"
ip route del "${public_ip}/32"
ip route del 0.0.0.0/1
ip route del 128.0.0.1/1
ip addr del dev tun0 "$(/sbin/ip -4 addr show tun0 | grep -w 'inet' | awk '{print $2}')"

plugin openvpn-plugin-down-root.so "/sbin/ip route delete "
