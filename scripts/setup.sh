#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck source=/dev/null
source /etc/openvpn/utils.sh

# test DNS resolution
if ! nslookup "${HEALTH_CHECK_HOST:-'google.com'}" &>/dev/null; then
  echo "WARNING: initial DNS resolution test failed"
fi

# create /dev/net/tun
if [[ "${CREATE_TUN_DEVICE,,}" == "true" ]]; then
  echo "Creating TUN device /dev/net/tun"
  rm -f /dev/net/tun
  mkdir -p /dev/net
  mknod /dev/net/tun c 10 200
  chmod 0666 /dev/net/tun
fi

# setup OpenVPN - this means downloading config(s), and setting user/password if not using docker secrets

# if no OPENVPN_PROVIDER is given, we default to "custom" provider.
VPN_PROVIDER="${OPENVPN_PROVIDER:-custom}"
export VPN_PROVIDER="${VPN_PROVIDER,,}" # to lowercase
export VPN_PROVIDER_HOME="/etc/openvpn/${VPN_PROVIDER}"
mkdir -p "${VPN_PROVIDER_HOME}"
echo "Using OpenVPN provider: ${VPN_PROVIDER^^}"

if [[ "${VPN_PROVIDER}" != 'custom' ]]; then
  if [[ -x "${VPN_PROVIDER_HOME}/configure-openvpn.sh" ]]; then
    echo "Executing setup script for ${VPN_PROVIDER}"
    # shellcheck source=/dev/null
    source "${VPN_PROVIDER_HOME}/configure-openvpn.sh"
  elif ! find "${VPN_PROVIDER_HOME}" -type f | grep -q 'ovpn'; then
    # shellcheck source=openvpn/fetch-external-configs.sh
    /etc/openvpn/fetch-external-configs.sh
  fi
fi

mkdir -p /config
chmod 0700 /config
chown abc:abc /config

if [[ -f /run/secrets/vpncreds ]]; then
  if [[ ! -f /config/openvpn-credentials.txt ]] || cmp -s /run/secrets/vpncreds /config/openvpn-credentials.txt; then
    echo "Setting OpenVPN credentials..."
    cp /run/secrets/vpncreds /config/openvpn-credentials.txt
  fi
else
  if [[ -z "${OPENVPN_USERNAME}" ]] || [[ -z "${OPENVPN_PASSWORD}" ]]; then
    if [[ ! -f /config/openvpn-credentials.txt ]]; then
      echo "OpenVPN credentials not set. Exiting."
      exit 1
    fi
    echo "Found existing OpenVPN credentials at /config/openvpn-credentials.txt"
  else
    echo "Setting OpenVPN credentials..."
    echo -e "${OPENVPN_USERNAME}\n${OPENVPN_PASSWORD}" > /config/openvpn-credentials.txt
    chmod 0400 /config/openvpn-credentials.txt
    chown abc:abc /config/openvpn-credentials.txt
  fi
fi

if [[ -n "${OPENVPN_CONFIG}" ]]; then
  # check that the chosen config exists.
  if [[ -f "${VPN_PROVIDER_HOME}/${OPENVPN_CONFIG}.ovpn" ]]; then
    echo "Starting OpenVPN using config ${OPENVPN_CONFIG}.ovpn"
    CHOSEN_OPENVPN_CONFIG="${VPN_PROVIDER_HOME}/${OPENVPN_CONFIG}.ovpn"
    # ensure the run script can get this variable
    printf '%s' "${CHOSEN_OPENVPN_CONFIG}" > /run/s6/container_environment/CHOSEN_OPENVPN_CONFIG
  else
    echo "Supplied config ${OPENVPN_CONFIG}.ovpn could not be found."
    echo "Your options for this provider are:"
    find "${VPN_PROVIDER_HOME}" -type f -iname "*.ovpn" -print
    echo "NB: Remember to not specify .ovpn as part of the config name."
    exit 1
  fi
else
  echo "No VPN configuration provided. Using default."
  CHOSEN_OPENVPN_CONFIG="${VPN_PROVIDER_HOME}/default.ovpn"
  # ensure the run script can get this variable
  printf '%s' "${CHOSEN_OPENVPN_CONFIG}" > /run/s6/container_environment/CHOSEN_OPENVPN_CONFIG
fi

# log message and fail if attempting to mount config directly
if mountpoint -q "${CHOSEN_OPENVPN_CONFIG}"; then
  fatal_error "You're mounting a openvpn config directly, don't do this it causes issues (see upsteam #2274). Mount the directory where the config is instead."
fi

MODIFY_CHOSEN_CONFIG="${MODIFY_CHOSEN_CONFIG:-true}"
# The config file we're supposed to use is chosen, modify it to fit this container setup
if [[ "${MODIFY_CHOSEN_CONFIG,,}" == "true" ]]; then
  # shellcheck source=openvpn/modify-openvpn-config.sh
  /etc/openvpn/modify-openvpn-config.sh "${CHOSEN_OPENVPN_CONFIG}"
fi

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
  if [[ "${UFW_DISABLE_IPTABLES_REJECT,,}" == "true" ]]; then
    # A horrible hack to ufw to prevent it detecting the ability to limit and REJECT traffic
    sed -i 's/return caps/return []/g' /usr/lib/python3/dist-packages/ufw/util.py
    # force a rewrite on the enable below
    echo "Disable and blank firewall"
    ufw disable
    echo "" > /etc/ufw/user.rules
  fi

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
      readarray -t remotes < <(grep '^remote ' "${CHOSEN_OPENVPN_CONFIG}" | sort -V | awk '{print $2,$3}')
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

