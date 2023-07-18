#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $DIR

if [[ -f /proc/version ]] && [[ "$( grep Microsoft /proc/version )" ]]; then
  PACKER="packer.exe"
else
  PACKER="packer"
fi

if [[ ! -e ./vsphere-environment-do-not-add ]]
then
  echo "Please add a vsphere-environment-do-not-add file to set up the environment variables required to deploy"
  echo "These vary based on the target VMWare server. The list can be found at the bottom of the packer template."
  return 1
fi
source ./vsphere-environment-do-not-add

echo 'creating output directory'
mkdir -p output
rm -rf ./output/packer-rocky-9-x86_64-vmware

echo 'building base images'
${PACKER} build \
  -only=vsphere-iso.rocky-9 \
  -var 'build_directory=./output/' \
  -var 'disk_size=150000' \
  -var 'cpus=2' \
  -var 'memory=4096' \
  -var 'box_basename=ccdc-basebox/rocky-9' \
  ./rocky-9-x86_64.json.pkr.hcl
