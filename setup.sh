#!/bin/sh

# based off https://www.raspberrypi.com/documentation/computers/configuration.html#setting-up-a-routed-wireless-access-point

# Install AP and Management Software

sudo apt install hostapd
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

sudo apt install dnsmasq

sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

# Set up the Network Router

## Define the Wireless Interface IP Configuration
sudo echo "interface wlan0"                        >> /etc/dhcpcd.conf
sudo echo "    static ip_address=192.168.220.1/24" >> /etc/dhcpcd.conf
sudo echo "    nohook wpa_supplicant"              >> /etc/dhcpcd.conf

## Configure the DHCP and DNS services for the wireless network
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo echo "interface=wlan0"                                           >> /etc/dnsmasq.conf
sudo echo "dhcp-range=192.168.220.2,192.168.220.30,255.255.255.0,24h" >> /etc/dnsmasq.conf
sudo echo "domain=wlan"                                               >> /etc/dnsmasq.conf
sudo echo "address=/mini.polyfab/192.168.220.1"                       >> /etc/dnsmasq.conf

sudo rfkill unblock wlan

MINI=${1:-1}

echo "country_code=CA"          >> /etc/hostapd/hostapd.conf
echo "interface=wlan0"          >> /etc/hostapd/hostapd.conf
echo "ssid=MINI$MINI"           >> /etc/hostapd/hostapd.conf
echo "hw_mode=g"                >> /etc/hostapd/hostapd.conf
echo "channel=7"                >> /etc/hostapd/hostapd.conf
echo "macaddr_acl=0"            >> /etc/hostapd/hostapd.conf
echo "auth_algs=1"              >> /etc/hostapd/hostapd.conf
echo "ignore_broadcast_ssid=0"  >> /etc/hostapd/hostapd.conf
echo "wpa=2"                    >> /etc/hostapd/hostapd.conf
echo "wpa_passphrase=polyfab1"  >> /etc/hostapd/hostapd.conf
echo "wpa_key_mgmt=WPA-PSK"     >> /etc/hostapd/hostapd.conf
echo "wpa_pairwise=TKIP"        >> /etc/hostapd/hostapd.conf
echo "rsn_pairwise=CCMP"        >> /etc/hostapd/hostapd.conf

sudo systemctl reboot
