#!/usr/bin/env bash

set -e
set -x

# Save Dockerfiles relative to this path so that this script can be run from
# any directory. https://stackoverflow.com/a/246128/5666087
DIR="$(dirname "$0")"

BASE_IMAGES="centos:7.4.1708  debian:stretch-20170907 ubuntu:xenial-20170802"
FLAGS=("--ants version=2.2.0" "--ants version=2.1.0" "--fsl version=5.0.10" "--fsl version=5.0.9")

for base in $BASE_IMAGES; do
  for flag in "${FLAGS[@]}"; do

    if [[ "$base" == "centos"* ]]; then
      pkg_manager="yum"
    else
      pkg_manager="apt"
    fi

    file_suffix1="$(echo "$base" | sed -e 's/\./-/g' -e 's/:/-/g' )"
    file_suffix2="$(echo "$flag" | sed 's/--\(.*\)\ /\1/' | sed 's/version=/-/g')"
    filename="${DIR}/Dockerfile.${file_suffix1}_${file_suffix2}"

    docker run --rm kaczmarj/neurodocker:v0.3.0 generate \
    --base "$base" --pkg-manager "$pkg_manager" \
    --copy *.py environment.yml /opt/repronim/simple_workflow/scripts/ \
    --copy expected_output expected_output \
    --miniconda env_name=bh_demo \
    --run "conda env create -q --force --file /opt/repronim/simple_workflow/scripts/environment.yml && conda clean -tipsy" \
    $flag \
    --workdir /opt/repronim/simple_workflow/scripts > $filename

  done
done
