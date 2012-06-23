#!/bin/sh
killall jackd
killall mongrel2
killall m2sh

# this is so that later sudos are handled.
sudo echo Sudo Up.
sudo bash init-swarmed-network.sh
sudo /etc/init.d/dnsmasq restart
cd ~/projects/mongrel2-musical-relay/
urxvt +j -e bash jackd.sh &
sleep 1
urxvt +j -title 'MONGREL2' -e make start &
urxvt +j -e perl 404.pl &
urxvt +j -e perl 404.pl &
urxvt +j -e perl http_harbinger.pl &
urxvt +j -e perl http_harbinger.pl &
sleep 1
bash ~/projects/swarmed/instr.sh
qjackctl &
