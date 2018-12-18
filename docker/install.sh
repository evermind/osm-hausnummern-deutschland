#!/bin/sh

if [ -z "$1" ]; then
  echo "USAGE: $0 TARGET-DIRECTORY"
  exit 1
fi

if ! mountpoint -q "$1" ; then
  echo "ERROR: $1 is not mounted"
  exit 1
fi

echo "Installing to $1"
cp -a /data $1
echo "done."

