# Packer Rocky Linux base images

This repository contains Packer templates and Ansible provisioning for Rocky Linux
base images. The Proxmox configuration builds Rocky Linux 8.10 and 9.8 templates.

## Proxmox Rocky templates

Run Packer from the `proxmox` directory on a Linux or macOS build host. Install
Packer, Ansible, `ansible-galaxy`, `sshpass`, Git and an ISO creation tool such as
`xorriso`.

For Ubuntu 24.04, including WSL, install the prerequisites with:

```sh
sudo apt update
sudo apt install -y ansible ca-certificates curl git gnupg python3.12 python3.12-venv sshpass xorriso
```

Install Packer using the [official installation instructions](https://developer.hashicorp.com/packer/install).
The Proxmox template requires Packer 1.16.1 or later.

The build host needs HTTPS access to GitHub and Ansible Galaxy to install
provisioning dependencies, and SSH access to the guest on its configured network.
The guest needs network access to package repositories during installation and
provisioning. The Proxmox ISO storage must accept the generated kickstart ISO.

### Rocky 8 Ansible environment

Rocky 8's system DNF bindings use Python 3.6, which recent ansible-core releases do
not support. Use an isolated ansible-core 2.16 environment for Rocky 8; it supports
Python 3.6 targets but is end-of-life and no longer receives security fixes. The
Rocky 8 configuration selects the guest's `/usr/libexec/platform-python` and a
separate Galaxy requirements file.

On the build host, install Python 3.12 with virtual environment support, then run:

```sh
python3.12 -m venv "$HOME/packer_ansible_env"
. "$HOME/packer_ansible_env/bin/activate"
python -m pip install 'ansible-core>=2.16,<2.17'
```

Keep this environment active for the Rocky 8 build. Run `deactivate` afterwards
to return to the host's normal Ansible installation for Rocky 9. Check that the
Rocky 9 Ansible version supports the selected Galaxy dependencies; Ubuntu's
packaged version may be too old for the latest collections.

### Configuration and build

Set `PROXMOX_URL` to the Proxmox API URL ending in `/api2/json`,
`PROXMOX_USERNAME` to `user@realm!token-id`, and `PROXMOX_TOKEN` to the token
secret. The API token needs permissions for the target infrastructure.

Configure `node_name`, `storage_pool`, `iso_storage_pool`, and `network_bridge`
for your environment using Packer `-var` arguments or a variables file. The disk
storage must support raw images by default; the ISO storage must support ISO
images. Set `insecure_skip_tls_verify` only when needed for a trusted Proxmox
server with a self-signed certificate (as seen in the examples below).

Download the Rocky Linux 8.10 and 9.8 minimal ISOs from the
[Rocky Linux downloads](https://rockylinux.org/download) page and upload them to
ISO-enabled storage on Proxmox. Set `iso_file` to the matching Proxmox ISO volume
ID, replacing the example values below with your own.

With the Rocky 8 Ansible environment active, initialize and build Rocky 8:

```sh
cd proxmox
packer init .
packer validate -var-file=rocky8.pkrvars.hcl \
 -var='node_name=<node>' -var='storage_pool=<disk-storage>' \
 -var='iso_storage_pool=<iso-storage>' -var='insecure_skip_tls_verify=true' \
 -var='iso_file=<iso-storage>:iso/Rocky-8.10-x86_64-minimal.iso' .
packer build -var-file=rocky8.pkrvars.hcl \
 -var='node_name=<node>' -var='storage_pool=<disk-storage>' \
 -var='iso_storage_pool=<iso-storage>' -var='insecure_skip_tls_verify=true' \
 -var='iso_file=<iso-storage>:iso/Rocky-8.10-x86_64-minimal.iso' .
```

Deactivate the Rocky 8 environment, then validate and build Rocky 9 using an
appropriate host Ansible installation:

```sh
deactivate
packer validate -var-file=rocky9.pkrvars.hcl \
 -var='node_name=<node>' -var='storage_pool=<disk-storage>' \
 -var='iso_storage_pool=<iso-storage>' -var='insecure_skip_tls_verify=true' \
 -var='iso_file=<iso-storage>:iso/Rocky-9.8-x86_64-minimal.iso' .

packer build -var-file=rocky9.pkrvars.hcl \
 -var='node_name=<node>' -var='storage_pool=<disk-storage>' \
 -var='iso_storage_pool=<iso-storage>' -var='insecure_skip_tls_verify=true' \
 -var='iso_file=<iso-storage>:iso/Rocky-9.8-x86_64-minimal.iso' .
```

The installer uses DHCP, disables the firewall, sets SELinux to permissive and
creates a `vagrant` account with password `vagrant` and passwordless sudo for
provisioning. Secure the resulting templates and clones before use. The disk
layout reserves 16 GB for swap.

## Further reading

- [Packer documentation](https://developer.hashicorp.com/packer/docs)
- [Bento](https://github.com/chef/bento), which inspired the original base boxes
