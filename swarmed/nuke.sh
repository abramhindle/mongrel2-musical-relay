killall urxvt
killall jackd
killall mongrel2
killall m2sh
killall csound
killall qjackctl
killall qjackctl
killall qjackctl
killall qjackctl.real
killall jackdbus 
killall -9 jackdbus 
killall -9 mongrel2
killall -9 m2sh
rm -rf /home/hindle1/projects/mongrel2-musical-relay/run/
sudo killall dnsmasq
sudo killall -9 dnsmasq
killall sclang
killall scsynth
sudo cp /etc/dnsmasq.conf.orig /etc/dnsmasq.conf
echo 'echo nameserver 8.8.8.8 >> /etc/resolv.conf' | sudo sh -
