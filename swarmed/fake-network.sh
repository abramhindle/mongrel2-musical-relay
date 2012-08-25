#!/bin/sh
sudo ifconfig eth0 down
sudo ifconfig eth0 up 10.20.30.1 netmask 255.255.255.0
