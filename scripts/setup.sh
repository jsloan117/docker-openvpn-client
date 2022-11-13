#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck source=/dev/null
source /etc/openvpn/utils.sh

if [[ -n "${REVISION}" ]]; then
  echo "GitRevision: ${REVISION}"
fi

if [[ -n "${VERSION}" ]]; then
  echo "GitVersion: ${VERSION}"
fi

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

# # add OpenVPN user/pass or use docker secrets
# if [[ ! -f /run/secrets/vpncreds ]]; then
#   if [[ -z "${OPENVPN_USERNAME}" ]] || [[ -z "${OPENVPN_PASSWORD}" ]]; then
#     if [[ ! -f /config/vpncreds ]]; then
#       echo "OpenVPN credentials not set. Exiting."
#       exit 1
#     fi
#     echo "OpenVPN credentials found"
#   else
#     echo "Setting OpenVPN credentials..."
#     mkdir -p /config
#     chmod 700 /config
#     chown abc:abc /config
#     echo "${OPENVPN_USERNAME}" > /config/vpncreds
#     echo "${OPENVPN_PASSWORD}" >> /config/vpncreds
#     chmod 0400 /config/vpncreds
#     chown abc:abc /config/vpncreds
#   fi
# else
#   echo "Using docker secrets"
# fi

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

# This is causing a sed error when mounting ovpn file due to inode disk busy
# # set path to vpncreds
# if [[ -f /run/secrets/vpncreds ]]; then
#   sed -i "s#auth-user-pass.*#auth-user-pass /run/secrets/vpncreds#g" "${CHOSEN_OPENVPN_CONFIG}"
# else
#   sed -i "s#auth-user-pass.*#auth-user-pass /config/vpncreds#g" "${CHOSEN_OPENVPN_CONFIG}"
# fi

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
