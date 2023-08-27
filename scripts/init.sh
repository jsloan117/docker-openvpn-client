#!/command/with-contenv bash
# shellcheck shell=bash
# called via "S6_STAGE2_HOOK" to setup openvpn or wireguard services

# shellcheck disable=SC2154
if [[ ${VPN_CLIENT,,} = 'openvpn' ]]; then
  if [[ ${ENABLE_UFW,,} = true ]]; then
    services='{init-openvpn,svc-ufw,svc-openvpn}'
  else
    services='{init-openvpn,svc-openvpn}'
  fi
  # cp -R /services/{init-openvpn,svc-ufw,svc-openvpn} /etc/s6-overlay/s6-rc.d
  cp -R "/services/${services}" /etc/s6-overlay/s6-rc.d
  if [[ ${ENABLE_UFW,,} = false ]]; then
    rm -f /etc/s6-overlay/s6-rc.d/svc-openvpn/dependencies.d/svc-ufw
    touch /etc/s6-overlay/s6-rc.d/svc-openvpn/dependencies.d/init-openvpn
  fi
  # cp /services/user/contents.d/{init-openvpn,svc-ufw,svc-openvpn} /etc/s6-overlay/s6-rc.d/user/contents.d
  cp "/services/user/contents.d/${services}" /etc/s6-overlay/s6-rc.d/user/contents.d
elif [[ ${VPN_CLIENT,,} = 'wireguard' ]]; then
  cp -R /services/svc-wireguard /etc/s6-overlay/s6-rc.d
  cp /services/user/contents.d/svc-wireguard /etc/s6-overlay/s6-rc.d/user/contents.d
fi

