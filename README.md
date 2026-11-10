# Packer Rocky Linux base images

This repository contains Packer templates and Ansible provisioning for Rocky Linux
base images. The Proxmox configuration builds Rocky Linux 8.10 and 9.8 templates.

## Build configurations

| Platform | Rocky Linux versions | Packer files |
| --- | --- | --- |
| Proxmox | 8.10, 9.8 | `proxmox/rocky.pkr.hcl` and the matching `rocky*.pkrvars.hcl` |
| VMware vSphere | 8.10, 9.8 | `vsphere/rocky.pkr.hcl` and the matching `rocky*.pkrvars.hcl` |

The vSphere configurations have not been verified against a vSphere environment.

## Requirements

On a Linux or macOS build host, install Packer, Ansible, `ansible-galaxy`,
`sshpass`, Git and an ISO creation tool such as `xorriso`.

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

## Rocky 8 Ansible environment

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

## Build a Proxmox template

Fill in the empty values in the relevant Rocky variables file for your environment:
`proxmox_url` (ending in `/api2/json`), `username` (`user@realm!token-id`),
`node_name`, `storage_pool`, `iso_storage_pool`, `additional_iso_storage_pool`,
`bridge`, `model` and `iso_file`. The `model` can be `virtio`; set `vlan_tag`
to `0` for no VLAN tag. The disk storage must support raw images by default, and
both ISO storage pools must support ISO images. The additional ISO storage is
used for the generated kickstart ISO.

Set `PROXMOX_TOKEN` to the token secret; the API token needs permissions for the
target infrastructure. Blank values in the variables files override the defaults,
including `PROXMOX_URL` and `PROXMOX_USERNAME`. Alternatively, override them with
Packer `-var` arguments or a later variables file. Set `insecure_skip_tls_verify`
only when needed for a trusted Proxmox server with a self-signed certificate.

Download the Rocky Linux 8.10 and 9.8 minimal ISOs from the
[Rocky Linux downloads](https://rockylinux.org/download) page and upload them to
ISO-enabled storage on Proxmox. Set `iso_file` to the matching Proxmox ISO volume
ID, for example `local:iso/Rocky-8.10-x86_64-minimal.iso`.

With the Rocky 8 Ansible environment active, initialise and build Rocky 8:

```sh
cd proxmox
packer init .
packer validate -var-file=rocky8.pkrvars.hcl .
packer build -var-file=rocky8.pkrvars.hcl .
```

Deactivate the Rocky 8 environment, then validate and build Rocky 9 using an
appropriate host Ansible installation:

```sh
deactivate
packer validate -var-file=rocky9.pkrvars.hcl .
packer build -var-file=rocky9.pkrvars.hcl .
```

Alternatively, from the repository root, export the connection settings and pass
the remaining values on the command line. Replace the example values for your
environment. This example skips TLS verification for a trusted self-signed server;
remove that argument when it is not needed.

```bash
export PROXMOX_URL='https://your-proxmox-host:8006/api2/json'
export PROXMOX_USERNAME='user@realm!token-id'
read -rs -p 'Proxmox token: ' PROXMOX_TOKEN
printf '\n'
export PROXMOX_TOKEN

cd proxmox
packer init .
packer build -var-file=rocky9.pkrvars.hcl \
 -var="proxmox_url=$PROXMOX_URL" -var="username=$PROXMOX_USERNAME" \
 -var='proxmox_name=ccdc-basebox-rocky-9.8-new' \
 -var='node_name=px01' -var='storage_pool=synology01' \
 -var='iso_storage_pool=synology01' -var='additional_iso_storage_pool=synology01' \
 -var='iso_file=synology01:iso/Rocky-9.8-x86_64-minimal.iso' \
 -var='bridge=vmbr1' -var='vlan_tag=26' -var='model=virtio' \
 -var='insecure_skip_tls_verify=true' .
```

The installer uses DHCP, disables the firewall, sets SELinux to permissive and
creates a `vagrant` account with password `vagrant` and passwordless sudo for
provisioning. Secure the resulting templates and clones before use. The separate
Proxmox Rocky 8 and 9 kickstarts share the installation and provisioning setup
based on Rocky 8, while retaining version-specific package exclusions. Both use
automatic LVM partitioning rather than a fixed 16 GB swap volume.

Both Proxmox kickstarts exclude Intel Wi-Fi firmware using `iwl*-firmware`
and explicitly exclude ALSA firmware without excluding audio libraries or
utilities. They retain `linux-firmware` for broader hardware compatibility.
Rocky 8 retains its existing exclusions for `cockpit`, `quota` and
`microcode_ctl`; these are not applied to Rocky 9. Keep CPU microcode updated
on the Proxmox host.

## Build a vSphere template

The `vsphere` directory contains a separate Packer configuration for Rocky Linux
8.10 and 9.8. The build host needs Packer, Ansible, `ansible-galaxy`, `sshpass`,
Git and an ISO creation tool. The host must reach vSphere, GitHub, Ansible Galaxy
and the guest over SSH. The guest needs access to package repositories.

Copy `vsphere/vsphere-environment-do-not-add-sample` to
`vsphere/vsphere-environment-do-not-add`, configure it for your environment and
load it in your shell. The latter file is ignored by Git and contains credentials.
The ISO is downloaded from the configured mirror; review the ISO URL and checksum
in the selected variables file when using a different image.

The vSphere configuration retains the original shared Ansible requirements and
interpreter selection. Its Rocky 8 provisioning has not been validated with the
Ansible 2.16 environment described above; check dependency compatibility before
building. For Rocky 9, use an Ansible version compatible with its Galaxy requirements.

```sh
cd vsphere
. ./vsphere-environment-do-not-add
packer init .
packer validate -only=vsphere-iso.redhat -var-file=rocky9.pkrvars.hcl .
packer build -only=vsphere-iso.redhat -var-file=rocky9.pkrvars.hcl .
```

These vSphere builds have not been verified against a vSphere environment. The
kickstarts create a `vagrant` account with password `vagrant` and passwordless
sudo, disable the firewall and set SELinux to permissive. Secure templates and
clones before use.

The original VMware Workstation builder and Vagrant box settings are also retained
in the `vsphere` directory. The builder needs review before use: its original
`disk_controller_type` setting is rejected by the current VMware plugin.

## Further reading

- [Packer documentation](https://developer.hashicorp.com/packer/docs)
- [Bento](https://github.com/chef/bento), which inspired the original base boxes
