#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd $DIR

if [[ "$( grep Microsoft /proc/version )" ]]; then
  PACKER="packer.exe"
else
  PACKER="packer"
fi

echo 'creating output directory'
mkdir -p output

echo 'cleaning up intermediate output'
rm -rf ./output//packer-centos-8.1-x86_64-vmware

echo 'building base images'
$PACKER build \
  -only=vmware-iso \
  -except=vsphere,vsphere-template \
  -var 'build_directory=./output/' \
  -var 'disk_size=400000' \
  -var 'cpus=2' \
  -var 'memory=4096' \
  -var 'vmx_remove_ethernet_interfaces=true' \
  -var 'box_basename=ccdc-basebox/centos-8.1' \
  ./centos-8.1-x86_64.json


mv output/ccdc-basebox/centos-8.1.vmware.box output/ccdc-basebox/centos-8.1.$(date +%Y%m%d).0.vmware_desktop.box
