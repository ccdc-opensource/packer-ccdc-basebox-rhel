packer {
  required_version = ">= 1.7.0"

  required_plugins {
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = ">= 1.0.0"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

locals {
  http_directory = "${path.root}/../http"
}

source "vmware-iso" "redhat" {
  boot_command         = ["<up><wait><tab> inst.text inst.ks=http://${var.ipaddress}:{{ .HTTPPort }}/${var.kickstart_file}<enter><wait>"]
  boot_wait            = "10s"
  cpus                 = var.cpus
  disk_controller_type = "pvscsi"
  disk_size            = var.disk_size
  guest_os_type        = var.vmware_guest_os_type
  headless             = var.headless
  http_directory       = local.http_directory
  iso_checksum         = var.iso_checksum
  iso_url              = var.iso_url
  memory               = var.memory
  network_adapter_type = "VMXNET3"
  output_directory     = var.output_directory
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "10000s"
  ssh_username         = "vagrant"
  vm_name              = "${var.vsphere_name}-${formatdate("YYYYMMDD", timestamp())}"
  vmx_data = {
    "cpuid.coresPerSocket" = "1"
    "disk.EnableUUID"      = "TRUE"
  }
}

source "vsphere-iso" "redhat" {
  boot_command         = ["<up><wait><tab> inst.text inst.ks=cdrom:/ks.cfg<enter><wait>"]
  boot_wait            = "10s"
  convert_to_template  = true
  CPUs                 = var.cpus
  RAM                  = var.memory
  disk_controller_type = ["pvscsi"]

  storage {
    disk_size             = var.disk_size
    disk_thin_provisioned = true
  }

  guest_os_type       = var.vsphere_guest_os_type
  host                = var.vmware_center_esxi_host
  cd_files            = ["${local.http_directory}/${var.kickstart_file}"]
  http_port_max       = var.port_max
  http_port_min       = var.port_min
  http_directory      = local.http_directory
  iso_checksum        = var.iso_checksum
  iso_url             = var.iso_url
  shutdown_command    = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password        = "vagrant"
  ssh_port            = 22
  ssh_timeout         = "10000s"
  ssh_username        = "vagrant"
  vm_name             = "${var.vsphere_name}-${formatdate("YYYYMMDD", timestamp())}"
  vcenter_server      = var.vmware_center_host
  username            = var.vmware_center_username
  password            = var.vmware_center_password
  insecure_connection = false
  datacenter          = var.vmware_center_datacenter
  datastore           = var.vmware_center_datastore
  cluster             = var.vmware_center_cluster_name

  network_adapters {
    network      = var.vmware_center_vm_network
    network_card = "vmxnet3"
  }
}

build {
  sources = ["source.vmware-iso.redhat", "source.vsphere-iso.redhat"]

  provisioner "ansible" {
    playbook_file        = var.ansible_playbook_file
    galaxy_file          = var.ansible_requirements_file
    roles_path           = var.ansible_roles_path
    galaxy_force_install = true
    user                 = "vagrant"
    use_proxy            = false
    extra_arguments = ["-e", "ansible_ssh_password=vagrant"]
  }

  post-processors {
    post-processor "vagrant" {
      except = ["vsphere-iso.redhat"]
      output = "${var.output_directory}/${var.vagrant_box}.${replace(replace(replace(source.type, "-iso", ""), "hyper-v", "hyperv"), "vmware", "vmware_desktop")}.box"
    }
  }
}
