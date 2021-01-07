#!/bin/bash

# Create run dir manually because it can't so that by itself
sudo mkdir -p /var/run/xl2tpd

# start all necessary components
sudo systemctl restart strongswan
echo "strongswan start code: $?"

sudo xl2tpd
echo "xl2tpd start code: $?"

sudo ipsec start
echo "ipsec start code: $?"

sleep 2

# connect ipsec, then l2tp
sudo ipsec up L2TP-PSK
echo "ipsec up code: $?"

sleep 2

echo "c BKJVPN" | sudo tee /var/run/xl2tpd/l2tp-control
echo "xl2tpd startup log:"

# Read log for 4 seconds
tail -f /var/log/xl2tpd.log | timeout 4 head -n 1000

# Set up subnet routes
sudo ip route add 192.168.55.0/24 dev ppp0
sudo ip route add 192.168.99.0/24 dev ppp0

# Show routes
echo "Routes set up:"
ip route show dev ppp0

LINE=''
while [[ $LINE != 'disconnect' ]]
do
	echo -n 'Type "disconnect" to disconnect> '
	read LINE
done

echo 'Disconnecting...'

echo "d BKJVPN" | sudo tee /var/run/xl2tpd/l2tp-control
echo "xl2tpd shutdown log:"
# Read log for 4 seconds
tail -f /var/log/xl2tpd.log | timeout 4 head -n 1000

sleep 4

sudo ipsec down L2TP-PSK
echo "ipsec down code: $?"

sleep 1

sudo ipsec stop
echo "ipsec stop code: $?"

sleep 1

sudo killall xl2tpd
echo "killall xl2tpd code: $?"

sleep 1

sudo systemctl stop strongswan
echo "strongswan stop code: $?"
