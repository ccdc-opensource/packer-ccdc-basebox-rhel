# Packer variables for building Rocky 8 basebox on Proxmox (replace the placeholders with your actual Proxmox configuration)
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

# Default values
proxmox_name                = "ccdc-basebox-rocky-8.10"
iso_url                     = "https://mirrors.melbourne.co.uk/rocky/8.10/isos/x86_64/Rocky-8.10-x86_64-minimal.iso"
iso_checksum                = "sha256:231d21db029e900b305d8e23ff7a61d06bb4e873cb170bd4a85f4e6dd896748f"
disk_size                   = "30G"
cpus                        = 2
ram_mb                      = 4096
kickstart_file              = "../http/proxmox/rocky-8/ks.cfg"
ansible_python_interpreter  = "/usr/libexec/platform-python"