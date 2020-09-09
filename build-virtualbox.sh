#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd $DIR

if [[ -f /proc/version ]] && [[ "$( grep Microsoft /proc/version )" ]]; then
  PACKER="packer.exe"
else
  PACKER="packer"
fi

echo 'creating output directory'
mkdir -p output
rm -rf ./output/packer-centos-8.2-x86_64-virtualbox

echo 'building base images'
$PACKER build \
  -only=virtualbox-iso \
  -except=vsphere,vsphere-template \
  -var 'build_directory=./output/' \
  -var 'disk_size=400000' \
  -var 'cpus=2' \
  -var 'memory=4096' \
  -var 'box_basename=ccdc-basebox/centos-8.2' \
  ./centos-8.2-x86_64.json

mv output/ccdc-basebox/centos-8.2.virtualbox.box output/ccdc-basebox/centos-8.2.$(date +%Y%m%d).0.virtualbox.box
