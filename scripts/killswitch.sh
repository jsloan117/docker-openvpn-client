#!/bin/bash
# killswitch.sh
# basic idea is that if VPN goes down the
# container won't be able to get the Internet
# if using wireguard: ip route list table 51820

# this is kinda duped for now from setup.sh
# need to figure out how to add this to setup.sh or attempt to dedupe

# disable IPv6
sed -i 's/IPV6=yes/IPV6=no/' /etc/default/ufw

# need to set a route to our local network
# /sbin/ip route list match 0.0.0.0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}'

# if we use UFW or the LOCAL_NETWORK we need to grab network config info
if [[ "${ENABLE_UFW,,}" == "true" ]] || [[ -n "${LOCAL_NETWORK}" ]]; then
  eval "$(/sbin/ip route list match 0.0.0.0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}')"
  # vpn GW/INT
  eval "$(/sbin/ip route list match 0.0.0.0 | awk '{if($5="tun0"){print "VPNGW="$3"\nVPNINT="$5; exit}}')"
  # If we use UFW_ALLOW_GW_NET along with ENABLE_UFW we need to know what our netmask CIDR is
  if [[ "${ENABLE_UFW,,}" == "true" ]] && [[ "${UFW_ALLOW_GW_NET,,}" == "true" ]]; then
    eval "$(/sbin/ip route list dev "${INT}" | awk '{if($5=="link"){print "GW_CIDR="$1; exit}}')"
  fi
fi

if [[ -n "${LOCAL_NETWORK}" ]]; then
  if [[ -n "${GW}" ]] && [[ -n "${INT}" ]]; then
    for localNet in ${LOCAL_NETWORK//,/ }; do
      echo "adding route to local network ${localNet} via ${GW} dev ${INT}"
      /sbin/ip route replace "${localNet}" via "${GW}" dev "${INT}"
      # allow local network access - make sure we can always get to it..
      ufw allow in on "${INT}" from "${localNet}"
      ufw allow out on "${INT}" to "${localNet}"
      # create array of vpn remotes
      readarray -t ips < <(grep '^remote ' "${CHOSEN_OPENVPN_CONFIG}" | awk '{print $2,$3}')
      for i in "${ips[@]}"; do
        eval "$(echo "${i}" | awk '{print "IP="$1"\nPORT="$2; exit}')"
        # allow outgoing to create tunnel
        ufw allow out on "${INT}" to "${IP}" port "${PORT}"
      done
      # allow all outgoing on VPN_INTERFACE
      ufw allow out on "${VPNINT}" from any to any
      # set defaults
      ufw default deny incoming
      ufw default deny outgoing
      ufw enable || ufw reload
      # if [[ "${ENABLE_UFW,,}" == "true" ]]; then
      #   if [[ -n "${UFW_EXTRA_PORTS}" ]]; then
      #     for port in ${UFW_EXTRA_PORTS//,/ }; do
      #       ufwAllowPortLong "${port}" "${localNet}"
      #     done
      #   fi
      # fi
    done
  fi
fi

# allow local network access - make sure we can always get to it..
ufw allow in on "$INT" from LOCAL_NETWORK
ufw allow out on "$INT" to LOCAL_NETWORK

# allow outgoing to create tunnel
# strict
# ufw allow out on $INT to VPN_IP port VPN_PORT -- Better?
# stricter
# ufw allow out on $INT from CONTAINER_IP to VPN_IP port VPN_PORT -- Better x2
ufw allow out to VPN_IP port VPN_PORT
# allow all outgoing on VPN_INTERFACE
ufw allow out on VPN_INTERFACE from any to any

# set defaults
ufw default deny incoming
ufw default deny outgoing

ufw enable || ufw reload

