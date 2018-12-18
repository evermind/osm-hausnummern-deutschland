#!/bin/bash

source ./env.sh

TAG=$( curl -s https://download.geofabrik.de/${MAP}.html | sed -rn "s/.*contains all OSM data up to (.*?)T.*/\1/p" )
if [ -z "${TAG}" ]; then
	echo "No map date found at https://download.geofabrik.de/ - check the website and the script $0" >&2
	exit 1
fi
echo ${MAP##*/}-${TAG}
