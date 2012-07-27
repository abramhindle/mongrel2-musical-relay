#!/bin/sh
echo 'echo "1" > /proc/sys/net/ipv4/ip_forward' | sudo sh
IP=10.20.30.1
sudo kill `ps aux | fgrep dhclient | fgrep eth0 | awk '{print $2}'`
sudo ifconfig eth0 up 10.20.30.1 netmask 255.255.255.0
sudo ufw disable
sudo iptables -F
sudo iptables -F -t nat
sudo iptables -P FORWARD DROP
sudo iptables -P INPUT ACCEPT
#sudo iptables -A INPUT  -p udp --dport 5353 -j REJECT
#sudo iptables -A INPUT  -p udp --dport 123 -j REJECT
#sudo iptables -A INPUT -i lo -j ACCEPT  
#sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#sudo iptables -A INPUT  -p tcp --dport 22 -j ACCEPT
#sudo iptables -A INPUT  -p tcp --dport 80 -j ACCEPT
#sudo iptables -A INPUT  -p tcp --dport 53 -j ACCEPT
#sudo iptables -A INPUT  -p udp --dport 53 -j ACCEPT
#sudo iptables -A INPUT  -p tcp --dport 6767 -j ACCEPT
#sudo iptables -A INPUT  -p tcp --dport 443 -j ACCEPT



#sudo iptables -t nat -I PREROUTING -p tcp -i eth0 -d 0/0 --dport 80 -j REDIRECT --to-port 6767
sudo iptables -t nat -I PREROUTING -p tcp -i eth0 -d 0/0 --dport 80 -j REDIRECT --to-port 80
#sudo iptables -t nat -I PREROUTING -p tcp -i eth0 -d 0/0 --dport 443 -j REDIRECT --to-port 6767
#sudo iptables -A PREROUTING -t nat -p tcp -d 0/0 --dport www -i eth0 -j REDIRECT --to-port 6767
#sudo iptables -A PREROUTING -t nat -p tcp -d 0/0 --dport 80 -i eth0 -j DNAT --to-destination 10.20.30.1:6767
sudo iptables -t nat -A POSTROUTING -j MASQUERADE
sudo iptables -A PREROUTING -t nat -p udp -d 0/0 --dport 53 -i eth0 -j REDIRECT --to-port 53
sudo iptables -A PREROUTING -t nat -p tcp -d 0/0 --dport 53 -i eth0 -j REDIRECT --to-port 53

#sudo echo nameserver 8.8.8.8 > /etc/resolv.conf
sudo /etc/init.d/dnsmasq restart
