#!/bin/bash

main=`uname  -r | awk -F . '{print $1 }'`

minor=`uname -r | awk -F . '{print $2}'`

apt update && apt install curl sudo lsb-release iptables -y

if [ -f "/etc/wireguard/wgcf.conf" ]; then

	echo "当前已经安装了wgcf"	exit 1

fi

if [ -f "/etc/apt/sources.list.d/backports.list" ]; then

	apt update

	else

	echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" | sudo tee /etc/apt/sources.list.d/backports.list

	apt update

fi

DEBIAN_FRONTEND=noninteractive apt install net-tools iproute2 openresolv dnsutils -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

DEBIAN_FRONTEND=noninteractive apt install wireguard-tools --no-install-recommends -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

curl -fsSL git.io/wgcf.sh | sudo bash

echo | wgcf register

wgcf generate

sed -i 's/engage.cloudflareclient.com/2606:4700:d0::a29f:c001/g' wgcf-profile.conf

sed -i 's/1.1.1.1/1.1.1.1,8.8.8.8,9.9.9.9/g' wgcf-profile.conf

sed -i '/\:\:\/0/d' wgcf-profile.conf

cp wgcf-profile.conf /etc/wireguard/wgcf.conf

systemctl enable wg-quick@wgcf

systemctl start wg-quick@wgcf
