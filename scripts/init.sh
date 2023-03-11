#!/command/with-contenv bash
# shellcheck shell=bash
# will be used in "S6_STAGE2_HOOK" to setup openvpn or wireguard services

# shellcheck disable=SC2154
if [[ ${VPN_CLIENT,,} == "openvpn" ]]; then
  cp -R /services/{init-openvpn,svc-openvpn} /etc/s6-overlay/s6-rc.d
  cp /services/user/contents.d/svc-openvpn /etc/s6-overlay/s6-rc.d/user/contents.d
elif [[ ${VPN_CLIENT,,} == "wireguard" ]]; then
  cp -R /services/svc-wireguard /etc/s6-overlay/s6-rc.d
  cp /services/user/contents.d/svc-wireguard /etc/s6-overlay/s6-rc.d/user/contents.d
fi

