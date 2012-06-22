jack_connect  csoundBouncey:output1 csoundDropMixer:input1

jack_connect  csoundClothe:output1 csoundDropMixer:input2

jack_connect  csoundForce:output1 csoundDropMixer:input3

jack_connect  csoundVoronoi:output1 csoundDropMixer:input4

jack_connect  csoundDropMixer:output1 system:playback_1
jack_connect  csoundDropMixer:output2 system:playback_2
jack_connect  csoundDropMixer:output3 system:playback_1
jack_connect  csoundDropMixer:output4 system:playback_2
