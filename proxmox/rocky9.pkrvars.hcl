# Packer variables for building Rocky 9 basebox on Proxmox (replace the placeholders with your actual Proxmox configuration)
# Environment Values
# node_name = ""
# proxmox_url = ""
# storage_pool = ""
# iso_file = ""
# additional_iso_storage_pool = ""
# bridge = ""
# vlan_tag = ""
# model = ""
# username = ""
# ansible_requirements_file = ""

# Default values
proxmox_name                = "ccdc-basebox-rocky-9.8"
iso_url                     = "https://mirrors.melbourne.co.uk/rocky/9.8/isos/x86_64/Rocky-9.8-x86_64-minimal.iso"
iso_checksum                = "sha256:d338032cd1cdd41c67139f2f71b4c832c8e4a21943106519db9c7137df7a63d4"
disk_size                   = "30G"
cpus                        = 2
ram_mb                      = 4096
ansible_python_interpreter  = "/usr/libexec/platform-python"
kickstart_file              = "../http/proxmox/rocky-9/ks.cfg"
