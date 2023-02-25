#!/command/with-contenv bash
# shellcheck shell=bash
# will be used in "S6_STAGE2_HOOK" to setup openvpn or wireguard services

# shellcheck disable=SC2154
if [[ ${VPN_SOLUTION} == "openvpn" ]]; then
  cp -R /services/{init-openvpn,openvpn} /etc/s6-overlay/s6-rc.d
  cp /services/user/contents.d/openvpn /etc/s6-overlay/s6-rc.d/user/contents.d
elif [[ ${VPN_SOLUTION} == "wireguard" ]]; then
  cp -R /services/wireguard /etc/s6-overlay/s6-rc.d
  cp /services/user/contents.d/wireguard /etc/s6-overlay/s6-rc.d/user/contents.d
fi

