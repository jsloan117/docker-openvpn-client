#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck source=/dev/null
source /etc/openvpn/utils.sh

# test DNS resolution
if ! nslookup "${HEALTH_CHECK_HOST:-'google.com'}" &>/dev/null; then
  echo "WARNING: initial DNS resolution test failed"
fi

# create /dev/net/tun
# shellcheck disable=SC2154
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

