cd ~/projects/mongrel2-musical-relay/
sleep 1
urxvt +j -e perl harbhandlegeneric.pl &
sleep 1
cd ~/projects/mixer
urxvt +j -e sh dropmixer.sh &
cd ~/projects/mongrel2-musical-relay/
sleep 1
bash mixerconnect.sh
