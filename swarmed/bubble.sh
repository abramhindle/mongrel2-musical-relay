#!/bin/sh
# START JACK AND SUPERCOLLIDER FIRST
#killall jackd
killall mongrel2
killall m2sh
killall http_enveloper.pl
#killall sclang
#killall scsynth

# this is so that later sudos are handled.
sudo echo Sudo Up.
sudo /etc/init.d/lighttpd stop
sudo /etc/init.d/apache2 stop
if [ $NOTREAL ]
then 
	echo not real 
	sudo bash fake-network.sh
else 
	echo real
	sudo bash init-swarmed-network.sh
	sudo /etc/init.d/dnsmasq restart
fi
cd ~/projects/mongrel2-musical-relay/
#urxvt +j -e bash jackd.sh &
sleep 1
urxvt +j -title 'MONGREL2' -e make start &
urxvt +j -e perl 404-bubble.pl &
urxvt +j -e perl http_bubble.pl &
#urxvt +j -e perl http_harbinger.pl &
sleep 1
#bash ~/projects/mongrel2-musical-relay/swarmed/instr.sh
#qjackctl &
#cd ~/projects/bubble-warp/
#emacs bubble.sc &
