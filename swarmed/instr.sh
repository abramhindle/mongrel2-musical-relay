cd ~/projects/mongrel2-musical-relay/
sleep 1
urxvt +j -title "perl Harbinger Handler" -e perl harbhandlegeneric.pl &
urxvt +j -title "perl Enveloper Handler" -e perl http_enveloper.pl &
sleep 1
cd ~/projects/mixer
urxvt +j -title "Drop Mixer" -e sh dropmixer.sh &
cd ~/projects/mongrel2-musical-relay/
sleep 1
bash mixerconnect.sh

