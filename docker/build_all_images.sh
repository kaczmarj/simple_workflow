#!/usr/bin/env bash

# Build all Docker images using the Dockerfiles in this Directory.
# Do this in parallel across 4 nodes.
# https://github.com/nipy/nipype/blob/8d530d33e379daca1b3df8a3e1b78ffe2305c00c/.circle/tests.sh

set -e
set -u
set -x

if [ "${CIRCLE_NODE_TOTAL:-}" != "3" ]; then
  echo "Builds are designed to run at 4x parallelism."
  exit 1
fi

DOCKERHUB_USER_REPO="kaczmarj/regtests"

DIR="$(dirname "$0")"
FILE_PATTERN="${DIR}/Dockerfile.*"

ALL_FILES="$(ls $FILE_PATTERN)"
N_BUILDS_PER_NODE="$(( $(echo $ALL_FILES | xargs -n1 | wc -l) / $CIRCLE_NODE_TOTAL ))"


case ${CIRCLE_NODE_INDEX} in
  0)
    for file in $(echo $ALL_FILES | xargs -n${N_BUILDS_PER_NODE} | head -1 | tail -1); do
      tag="$(echo $(basename "$file") | cut -d. -f2-)"
      # Retry building.
      # https://github.com/nipy/nipype/blob/ad085ae86c9dbb97aedb316562ea31f79c5923fe/circle.yml
      e=1 && for i in {1..5}; do
        docker build -t "${DOCKERHUB_USER_REPO}:${tag}" -f $file . && e=0 && break || sleep 15;
      done && [ "$e" -eq "0" ]

      docker push "${DOCKERHUB_USER_REPO}:${tag}"
    done
    ;;
  1)
    for file in $(echo $ALL_FILES | xargs -n${N_BUILDS_PER_NODE} | head -2 | tail -1); do
      tag="$(echo $(basename "$file") | cut -d. -f2-)"
      # Retry building.
      # https://github.com/nipy/nipype/blob/ad085ae86c9dbb97aedb316562ea31f79c5923fe/circle.yml
      e=1 && for i in {1..5}; do
        docker build -t "${DOCKERHUB_USER_REPO}:${tag}" -f $file . && e=0 && break || sleep 15;
      done && [ "$e" -eq "0" ]

      docker push "${DOCKERHUB_USER_REPO}:${tag}"
    done
    ;;
  2)
    for file in $(echo $ALL_FILES | xargs -n${N_BUILDS_PER_NODE} | head -3 | tail -1); do
      tag="$(echo $(basename "$file") | cut -d. -f2-)"
      # Retry building.
      # https://github.com/nipy/nipype/blob/ad085ae86c9dbb97aedb316562ea31f79c5923fe/circle.yml
      e=1 && for i in {1..5}; do
        docker build -t "${DOCKERHUB_USER_REPO}:${tag}" -f $file . && e=0 && break || sleep 15;
      done && [ "$e" -eq "0" ]

      docker push "${DOCKERHUB_USER_REPO}:${tag}"
    done
    ;;
esac
