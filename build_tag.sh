#!/bin/bash

set -e

source ./env.sh

URI="${MAP}-latest.osm.pbf"
FILE="${MAP##*/}-latest.osm.pbf"

rm -rf docker/data
mkdir -p docker/data
(
  echo "$( date ) Starting download of https://download.geofabrik.de/${URI}"
  wget --quiet -c https://download.geofabrik.de/${URI}

  echo "$( date ) Download done. Starting processing of multipolygons"

  cd docker/data

  ogr2ogr --config OSM_USE_CUSTOM_INDEXING NO --config OSM_CONFIG_FILE \
    ../../osmconf.ini --config SHAPE_ENCODING UTF-8 -f "ESRI Shapefile" hausnummern \
    ../../${FILE} -progress -overwrite -skipfailures -sql \
    "SELECT addr_housenumber addr_house FROM multipolygons WHERE building IS NOT NULL AND addr_housenumber IS NOT NULL"
 
  echo "$( date ) Multipolygons done. Starting processing of points"

  ogr2ogr --config OSM_USE_CUSTOM_INDEXING NO --config OSM_CONFIG_FILE \
    ../../osmconf.ini --config SHAPE_ENCODING UTF-8 -f "ESRI Shapefile" hausnummern \
    ../../${FILE} -progress -overwrite -skipfailures -sql \
    "SELECT addr_housenumber addr_house FROM points WHERE addr_housenumber IS NOT NULL"

  echo "$( date ) All done."
) &

PID=$!
(
  i=0
  while kill -0 $PID; do
    i=$(( i + 1 ))
    if [ $i -gt 180 ]; then
      i=0
      echo "$( date ) Still building, please wait  ..."
    fi
    sleep 1
  done
) &

wait

TAG=$1

docker build -t "${DOCKER_HUB_REPO}:${TAG}" docker/
if [ ! -z "${DOCKER_USERNAME}" -a ! -z "${DOCKER_PASSWORD}" ]; then
  docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
  docker push "${DOCKER_HUB_REPO}:${TAG}"
fi

