# Packer centos8 base box automation

This packer template creates a basic centos 8 box with a predefined administrator user called vagrant, based on the bento boxes.
The value of these images lies in the larger default size, a requirement given the amount of disk space consumed by our builds.

The scripts in this repository are date based. They will create and upload images with version number (current date).0.
It is therefore necessary to run them on the same day.

## How do I use this?

You need the following software installed:

- Packer: install it via choco install packer on windows or via brew on MacOS
- Virtualbox: required for creating an image that runs on virtualbox
- VMWare Fusion/Workstation: required for running an image that runs on VMWare

Once these are installed, open a command line window, cd in this directory and either or both

build-virtualbox.sh
build-vmware.sh

## Proxmox Rocky templates

Run Packer from the `proxmox` directory on a Linux or macOS machine with Ansible,
`ansible-galaxy`, `sshpass`, Git and an ISO creation tool such as `xorriso` installed.

For Ubuntu 24.04, including WSL, install the prerequisites with:

```sh
sudo apt update
sudo apt install -y ansible ca-certificates curl git gnupg python3.15 python3.15-venv sshpass xorriso
```

Then install Packer using the [official installation instructions](https://developer.hashicorp.com/packer/install).

Rocky 8's system DNF bindings use Python 3.6, which recent ansible-core releases do
not support. Use an isolated ansible-core 2.16 environment for Rocky 8 as it supports
Python 3.6 targets but is end-of-life and no longer receives security fixes.

On your host, install Python 3.15 with virtual environment support, then run the below, once complete you can deactivate:

```sh
python3.15 -m venv "$HOME/packer_ansible_env"
. "$HOME/packer_ansible_env/bin/activate"
python -m pip install 'ansible-core>=2.16,<2.17'
```

You will need to set `PROXMOX_URL` to the Proxmox API URL ending in `/api2/json`,
`PROXMOX_USERNAME` to `user@realm!token-id`, and `PROXMOX_TOKEN` to the token
secret, ensure the api token has the rights to the infrastructure. Configure `node_name`, `storage_pool`, `iso_storage_pool`, and
`network_bridge` for your environment with Packer `-var` arguments or a separate
variables file. The disk storage must support raw images by default; the ISO
storage must support ISO images. Set `insecure_skip_tls_verify` only if needed
for a trusted Proxmox server with a self-signed certificate.

Download the Rocky Linux 8.10 and 9.8 minimal ISOs from the
[Rocky Linux downloads](https://rockylinux.org/download) page and upload them to
ISO-enabled storage on Proxmox. Set `iso_file` to the corresponding Proxmox ISO
volume ID for each build, replacing the example paths below as needed.

```sh
cd proxmox
packer init .
packer validate -var-file=rocky8.pkrvars.hcl -var='node_name=your-node' -var='iso_file=<storage>:iso/Rocky-8.10-x86_64-minimal.iso' .
packer build -var-file=rocky8.pkrvars.hcl -var='node_name=your-node' -var='insecure_skip_tls_verify=true' -var='storage_pool=<storage>' -var='iso_file=<storage>:iso/Rocky-8.10-x86_64-minimal.iso' .
deactivate
packer build -var-file=rocky9.pkrvars.hcl -var='node_name=your-node' -var='insecure_skip_tls_verify=true' -var='storage_pool=<storage>' -var='iso_file=<storage>:iso/Rocky-9.8-x86_64-minimal.iso' .
```

## How do I make the boxes available?

In order to make an updated box available, you should upload it to the ccdc-vagrant-repo repository in artifactory
To do that, you first need to find out your api key. Head to [artifactory](https://artifactory.ccdc.cam.ac.uk/) and log in.
Sekect the ccdc-vagrant repository in the Set me up box on the main page. A dialog will pop up with a password box. Enter your password in the password box.
The curl url in the Deploy section will be updated with your api key. It's the string appearing after X-JFrog-Art-Api:
If the curl url doesn't have an X-JFrog-Art-Api: username but uses your username instead, click on the Welcome, (username) button on the top right corner in artifactory, and select 'Edit Profile', then unlock your profile and generate an API key.

Copy that key and run in a shell

  export ARTIFACTORY_API_KEY='key'

After that, run one or both scripts called upload-virtualbox.sh and upload-vmware.sh

## Where do I begin stydying this?

The [documentation on the bento repository](https://github.com/chef/bento) provides some insight on the process.
This repository simply taylors what's there to our needs (larger hard drive, boxes for vmware and virtualbox).

You should have a working understanding of [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) as they are used to pull the packer definitions from bento.

Why Packer? <https://www.packer.io/intro/why.html>

Packer documentation: <https://www.packer.io/docs/index.html>
