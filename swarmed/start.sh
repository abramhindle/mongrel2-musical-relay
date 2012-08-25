#!/bin/sh
sudo echo got sudo
killall jackd
killall mongrel2
killall m2sh

# this is so that later sudos are handled.
sudo echo Sudo Up.
sudo bash init-swarmed-network.sh
#sudo /etc/init.d/dnsmasq restart
cd ~/projects/mongrel2-musical-relay/
rm -rf ~/projects/mongrel2-musical-relay/run
mkdir ~/projects/mongrel2-musical-relay/run
urxvt +j -title "JACK" -e bash jackd.sh &
sleep 1
urxvt +j -title 'MONGREL2' -e make start &
# only 1 makes sense.
urxvt +j -title "404/Swarmed Handler" -e perl swarmed.pl &
#urxvt +j -e perl swarmed.pl &
urxvt +j -title "perl http harbinger" -e perl http_harbinger.pl &
urxvt +j -title "perl http harbinger" -e perl http_harbinger.pl &
sleep 1
bash ~/projects/mongrel2-musical-relay/swarmed/instr.sh
qjackctl &
