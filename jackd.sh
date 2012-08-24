ps aux | fgrep -v grep | fgrep pulseaudio | awk '{print $2}' | xargs kill
jackd -R  -d alsa -r 44100

