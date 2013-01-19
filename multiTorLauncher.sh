#!/bin/bash
# script from http://blog.databigbang.com/distributed-scraping-with-multiple-tor-circuits/

base_socks_port=50001
base_control_port=8119

# Create data directory if it doesn't exist
if [ ! -d "data" ]; then
	mkdir "data"
fi

for i in {0..5}

do
	j=$((i+1))
	socks_port=$((base_socks_port+i))
	control_port=$((base_control_port+i))
	if [ ! -d "data/tor$i" ]; then
		echo "Creating directory data/tor$i"
		mkdir "data/tor$i"
	fi
	# Take into account that authentication for the control port is disabled. Must be used in secure and controlled environments

	echo "Running: tor --RunAsDaemon 1 --CookieAuthentication 0 --HashedControlPassword \"\" --ControlPort $control_port --PidFile tor$i.pid --SocksPort $socks_port --DataDirectory data/tor$i"

	tor --RunAsDaemon 1 --CookieAuthentication 0 --HashedControlPassword "" --ControlPort $control_port --PidFile tor$i.pid --SocksPort $socks_port --DataDirectory data/tor$i
done