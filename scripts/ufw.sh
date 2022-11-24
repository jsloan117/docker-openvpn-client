#!/command/with-contenv bash
# shellcheck shell=bash

# if we use UFW or the LOCAL_NETWORK we need to grab network config info
if [[ "${ENABLE_UFW,,}" == "true" ]] || [[ -n "${LOCAL_NETWORK}" ]]; then
  eval "$(/sbin/ip route list match 0.0.0.0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}')"
  # If we use UFW_ALLOW_GW_NET along with ENABLE_UFW we need to know what our netmask CIDR is
  if [[ "${ENABLE_UFW,,}" == "true" ]] && [[ "${UFW_ALLOW_GW_NET,,}" == "true" ]]; then
    eval "$(/sbin/ip route list dev "${INT}" | awk '{if($5=="link"){print "GW_CIDR="$1; exit}}')"
  fi
fi

# open port to any address
function ufwAllowPort {
  portNum=${1}
  if [[ "${ENABLE_UFW,,}" == "true" ]] && [[ -n "${portNum}" ]]; then
    echo "allowing ${portNum} through the firewall"
    ufw allow "${portNum}"
  fi
}

# open port to specific address
function ufwAllowPortLong {
  portNum=${1}
  sourceAddress=${2}

  if [[ "${ENABLE_UFW,,}" == "true" ]] && [[ -n "${portNum}" ]] && [[ -n "${sourceAddress}" ]]; then
    echo "allowing ${sourceAddress} through the firewall to port ${portNum}"
    ufw allow from "${sourceAddress}" to any port "${portNum}"
  fi
}

if [[ "${ENABLE_UFW,,}" == "true" ]]; then
  # enable firewall
  echo "enabling firewall"
  sed -i 's/IPV6=yes/IPV6=no/' /etc/default/ufw
  ufw enable

  if [[ -n "${UFW_EXTRA_PORTS}" ]]; then
    for port in ${UFW_EXTRA_PORTS//,/ }; do
      if [[ "${UFW_ALLOW_GW_NET,,}" == "true" ]]; then
        ufwAllowPortLong "${port}" "${GW_CIDR}"
      else
        ufwAllowPortLong "${port}" "${GW}"
      fi
    done
  fi
fi

if [[ -n "${LOCAL_NETWORK}" ]]; then
  if [[ -n "${GW}" ]] && [[ -n "${INT}" ]]; then
    for localNet in ${LOCAL_NETWORK//,/ }; do
      echo "adding route to local network ${localNet} via ${GW} dev ${INT}"
      # Using `ip route replace` so that the command does not fail with
      # `RTNETLINK answers: File exists` when the route already exists
      /sbin/ip route replace "${localNet}" via "${GW}" dev "${INT}"
      if [[ "${ENABLE_UFW,,}" == "true" ]]; then
        if [[ -n "${UFW_EXTRA_PORTS}" ]]; then
          for port in ${UFW_EXTRA_PORTS//,/ }; do
            ufwAllowPortLong "${port}" "${localNet}"
          done
        fi
      fi
    done
  fi
fi

if [[ ${UFW_KILLSWITCH} = true ]]; then
  # vpn GW/INT
  eval "$(/sbin/ip route list match 0.0.0.0 | awk '{if($5="tun0"){print "VPNGW="$3"\nVPNINT="$5; exit}}')"
  if [[ -n "${VPNGW}" ]] && [[ -n "${VPNINT}" ]]; then
    for localNet in ${LOCAL_NETWORK//,/ }; do
      if [[ ${UFW_FAILSAFE} = true ]]; then
        echo "allowing inbound/outbound to/from ${localNet} on device ${INT}"
        # allow local network access - make sure we can always get to it
        ufw allow in on "${INT}" from "${localNet}"
        ufw allow out on "${INT}" to "${localNet}"
      fi
      # create array of vpn remotes
      readarray -t remotes < <(grep '^remote ' "${CHOSEN_OPENVPN_CONFIG}" | awk '{print $2,$3}')
      for remote in "${remotes[@]}"; do
        eval "$(echo "${remote}" | awk '{print "IP="$1"\nport="$2; exit}')"
        echo "allowing outbound to ${IP}:${port} on device ${INT}"
        # allow outgoing to create tunnel
        ufw allow out on "${INT}" to "${IP}" port "${port}"
      done
      echo "allowing all outbound traffic on device ${VPNINT}"
      # allow all outgoing on VPN_INTERFACE
      ufw allow out on "${VPNINT}" from any to any
      # set defaults
      echo "set UFW incoming and outgoing default to deny"
      ufw default deny incoming
      ufw default deny outgoing
      ufw reload
    done
  fi
fi

