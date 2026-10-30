
packer {
  required_version = ">= 1.16.1"

  required_plugins {
    ansible = {
      version = ">= 1.1.6"
      source  = "github.com/hashicorp/ansible"
    }
    proxmox = {
      version = ">= 1.2.4"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "rocky-kickstart" {
  boot_command         = ["<up><tab> inst.text inst.ks=hd:LABEL=OEMDRV:/ks.cfg<enter>"]
  boot_wait            = "10s"
  boot                 = "order=scsi0;ide0;ide1;net0"
  bios                 = "seabios"
  cores                = var.cpus
  memory               = var.ram_mb
  vm_name              = var.proxmox_name
  cpu_type             = "host"
  os                   = "l26"
  node                 = var.node_name
  proxmox_url          = var.proxmox_url
  username             = var.username
  token                = var.token
  ssh_password         = "vagrant"
  ssh_timeout          = "15m"
  ssh_username         = "vagrant"
  qemu_agent           = true
  scsi_controller      = "virtio-scsi-pci"
  template_description = "${var.proxmox_name}, generated on ${timestamp()}"
  template_name        = var.proxmox_name
  disks {
    disk_size           = var.disk_size
    storage_pool        = var.storage_pool
    type                = "scsi"
    exclude_from_backup = true
    format              = var.disk_format
  }

  insecure_skip_tls_verify = var.insecure_skip_tls_verify

  boot_iso {
    type             = "ide"
    index            = "0"
    iso_file         = var.iso_file
    iso_url          = var.iso_file == "" ? var.iso_url : ""
    iso_checksum     = var.iso_checksum
    iso_storage_pool = var.iso_storage_pool
    unmount          = true
  }

  additional_iso_files {
    type             = "ide"
    index            = "1"
    iso_storage_pool = var.iso_storage_pool
    cd_files         = [var.kickstart_file]
    cd_label         = "OEMDRV"
    unmount          = true
  }

  network_adapters {
    bridge = var.network_bridge
    model  = "virtio"
  }
}

build {
  sources = ["source.proxmox-iso.rocky-kickstart"]

  provisioner "shell" {
    inline = [
      "if [ -r /etc/os-release ]; then . /etc/os-release; fi",
      "case \"$ID:$VERSION_ID\" in rocky:8|rocky:8.*)",
      "  echo 'Rocky 8 DNF diagnostics:'",
      "  rpm -q python3-dnf || true",
      "  for python in /usr/libexec/platform-python /usr/bin/python3 /usr/bin/python /usr/bin/python3.11; do",
      "    echo \"Checking $python\"",
      "    if [ -x \"$python\" ]; then",
      "      \"$python\" -c 'import sys; print(sys.version); import dnf; print(dnf.__file__)' 2>&1 || true",
      "    else",
      "      echo 'Not installed'",
      "    fi",
      "  done",
      "  ;; esac",
    ]
  }

  provisioner "ansible" {
    playbook_file        = var.ansible_playbook_file
    galaxy_file          = var.ansible_requirements_file
    roles_path           = var.ansible_roles_path
    galaxy_force_install = true
    user                 = "vagrant"
    use_proxy            = false

    extra_arguments = [
      "-v",
      "-e",
      "ansible_ssh_password=vagrant",
    ]
  }
}
