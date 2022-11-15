#!/bin/bash

echo "$dev" > /etc/openvpn/args.txt

dns_options=$(printf '%s\n' ${!dns_*})
echo "${dns_options}" >> /etc/openvpn/args.txt
for dnsopt in ${dns_options}; do
  option="${!dnsopt}"
  echo "$option" >> /etc/openvpn/args.txt
done

foreign_options=$(printf '%s\n' ${!foreign_option_*} | sort -t _ -k 3 -g)
echo "${foreign_options}" >> /etc/openvpn/args.txt
for optionvarname in ${foreign_options} ; do
  option="${!optionvarname}"
  echo "$option" >> /etc/openvpn/args.txt
done

