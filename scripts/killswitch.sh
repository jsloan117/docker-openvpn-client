#!/command/with-contenv bash
# shellcheck shell=bash
# killswitch.sh
# basic idea is that if VPN goes down the
# container won't be able to get the Internet

# this is kinda duped for now from setup.sh
# need to figure out how to add this to setup.sh or attempt to dedupe

# disable IPv6
sed -i 's/IPV6=yes/IPV6=no/' /etc/default/ufw

# need to set a route to our local network
# /sbin/ip route list match 0.0.0.0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}
ip route add LOCAL_NETWORK via $GW dev $INT

# allow local network access - make sure we can always get to it..
ufw allow in on eth0 from LOCAL_NETWORK
ufw allow out on eth0 to LOCAL_NETWORK

# allow outgoing to create tunnel
# strict
# ufw allow out on eth0 to VPN_IP port VPN_PORT -- Better?
# stricter
# ufw allow out on eth0 from CONTAINER_IP to VPN_IP port VPN_PORT -- Better x2
ufw allow out to VPN_IP port VPN_PORT
# allow all outgoing on VPN_INTERFACE
ufw allow out on VPN_INTERFACE from any to any

# set defaults
ufw default deny incoming
ufw default deny outgoing

ufw enable || ufw reload

