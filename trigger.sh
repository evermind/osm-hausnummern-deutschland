#!/bin/bash

# This script triggers a builds if a tag does not exists yet on a github repository

fail() {
	echo "ERROR: $*"
	exit 1
}

tag_exists() {
	TAG=$1
	HTTP_STATUS=$( curl -s -o /dev/null -w '%{http_code}' https://index.docker.io/v1/repositories/${DOCKER_HUB_REPO}/tags/${TAG} )
	[ "$HTTP_STATUS" -ge 200 -a "$HTTP_STATUS" -le 299 ] || return 1
	return 0
}

set -e

# Read env vars
source ./env.sh

# Check vars, set defaults
[ ! -z "${DOCKER_HUB_REPO}" ] || fail "Please set DOCKER_HUB_REPO"
[ ! -z "${APP_NAME}" ] || export APP_NAME=$( basename ${PWD} ) 

# Check which release versions are available
echo "Checking for releases of ${APP_NAME}"

AVAILABLE_TAGS=$( ./get_available_tags.sh )

for TAG in ${AVAILABLE_TAGS}; do
	if tag_exists ${TAG}; then
		echo "Tag already exists: ${TAG}"
	else
		echo "Bulding tag: ${TAG}"
		./build_tag.sh ${TAG}
	fi
done

