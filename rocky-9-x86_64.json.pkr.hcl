packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "artifactory_api_key" {
  type    = string
  default = env("ARTIFACTORY_API_KEY")
}

variable "artifactory_username" {
  type    = string
  default = env("USER")
}

variable "box_basename" {
  type    = string
  default = "rocky-9"
}

variable "build_directory" {
  type    = string
  default = "../../builds"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "customise_for_buildmachine" {
  type    = string
  default = "0"
}

variable "disk_size" {
  type    = string
  default = "262144"
}

variable "git_revision" {
  type    = string
  default = "__unknown_git_revision__"
}

variable "guest_additions_url" {
  type    = string
  default = ""
}

variable "headless" {
  type    = bool
  default = false
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "hyperv_generation" {
  type    = string
  default = "1"
}

variable "hyperv_switch" {
  type    = string
  default = "${env("hyperv_switch")}"
}

variable "iso_checksum" {
  type    = string
  default = "cd43bb2671472471b1fc0a7a30113dfc9a56831516c46f4dbd12fb43bb4286d2"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_name" {
  type    = string
  default = "Rocky-9.2-x86_64-dvd.iso"
}

variable "ks_path" {
  type    = string
  default = "/9/ks.cfg"
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "mirror" {
  type    = string
  default = "https://mirrors.melbourne.co.uk"
}

variable "mirror_directory" {
  type    = string
  default = "rocky/9/isos/x86_64"
}

variable "name" {
  type    = string
  default = "rocky-9"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "output_directory" {
  type    = string
  default = "${env("PWD")}/output/"
}

variable "template" {
  type    = string
  default = "rocky-9-x86_64"
}

variable "vagrant_box" {
  type    = string
  default = "ccdc-basebox/rocky-9"
}

variable "vagrant_user_final_password" {
  type      = string
  default   = "${env("VAGRANT_USER_FINAL_PASSWORD")}"
  sensitive = true
}

variable "version" {
  type    = string
  default = "TIMESTAMP"
}

variable "vmware_center_cluster_name" {
  type    = string
  default = "${env("VMWARECENTER_CLUSTER_NAME")}"
}

variable "vmware_center_datacenter" {
  type    = string
  default = "${env("VMWARECENTER_DATACENTER")}"
}

variable "vmware_center_datastore" {
  type    = string
  default = "${env("VMWARECENTER_DATASTORE")}"
}

variable "vmware_center_esxi_host" {
  type    = string
  default = "${env("VMWARECENTER_ESXI_HOST")}"
}

variable "vmware_center_host" {
  type    = string
  default = "${env("VMWARECENTER_HOST")}"
}

variable "vmware_center_password" {
  type      = string
  default   = "${env("VMWARECENTER_PASSWORD")}"
  sensitive = true
}

variable "vmware_center_username" {
  type    = string
  default = "${env("VMWARECENTER_USERNAME")}"
}

variable "vmware_center_vm_folder" {
  type    = string
  default = "${env("VMWARECENTER_VM_FOLDER")}"
}

variable "vmware_center_vm_name" {
  type    = string
  default = "${env("VMWARECENTER_VM_NAME")}"
}

variable "vmware_center_vm_network" {
  type    = string
  default = "${env("VMWARECENTER_VM_NETWORK")}"
}
# The "legacy_isotime" function has been provided for backwards compatability, but we recommend switching to the timestamp and formatdate functions.

# All locals variables are generated from variables that uses expressions
# that are not allowed in HCL2 variables.
# Read the documentation for locals blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/locals
locals {
  http_directory  = "${path.root}/http"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "hyperv-iso" "rocky-9" {
  boot_command         = ["<wait5><tab> inst.text inst.ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
  boot_wait            = "10s"
  cpus                 = "${var.cpus}"
  disk_size            = "${var.disk_size}"
  floppy_files         = ["${local.http_directory}/${var.ks_path}"]
  generation           = "${var.hyperv_generation}"
  guest_additions_mode = "disable"
  http_directory       = "${local.http_directory}"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory               = "${var.memory}"
  output_directory     = "${var.build_directory}/packer-${var.template}-hyperv"
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "10000s"
  ssh_username         = "vagrant"
  switch_name          = "${var.hyperv_switch}"
  vm_name              = "${var.template}"
}

source "parallels-iso" "rocky-9" {
  boot_command           = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.ks_path}<enter><wait>"]
  boot_wait              = "10s"
  cpus                   = "${var.cpus}"
  disk_size              = "${var.disk_size}"
  guest_os_type          = "centos"
  http_directory         = "${local.http_directory}"
  iso_checksum           = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url                = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory                 = "${var.memory}"
  output_directory       = "${var.build_directory}/packer-${var.template}-parallels"
  parallels_tools_flavor = "lin"
  prlctl_version_file    = ".prlctl_version"
  shutdown_command       = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password           = "vagrant"
  ssh_port               = 22
  ssh_timeout            = "10000s"
  ssh_username           = "vagrant"
  vm_name                = "${var.template}"
}

source "qemu" "rocky-9" {
  boot_command     = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.ks_path}<enter><wait>"]
  boot_wait        = "10s"
  cpus             = "${var.cpus}"
  disk_size        = "${var.disk_size}"
  headless         = "${var.headless}"
  http_directory   = "${local.http_directory}"
  iso_checksum     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url          = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory           = "${var.memory}"
  output_directory = "${var.build_directory}/packer-${var.template}-qemu"
  shutdown_command = "echo 'vagrant'|sudo -S /sbin/halt -h -p"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "10000s"
  ssh_username     = "vagrant"
  vm_name          = "${var.template}"
}

source "virtualbox-iso" "rocky-9" {
  boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.ks_path}<enter><wait>"]
  boot_wait               = "10s"
  cpus                    = "${var.cpus}"
  disk_size               = "${var.disk_size}"
  guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_additions_url     = "${var.guest_additions_url}"
  guest_additions_interface = "sata"
  guest_additions_mode      = "disable"
  guest_os_type           = "RedHat_64"
  hard_drive_interface    = "sata"
  hard_drive_nonrotational = "true"
  hard_drive_discard      = "true"
  headless                = "${var.headless}"
  http_directory          = "${local.http_directory}"
  iso_checksum            = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url                 = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  iso_interface           = "sata"
  memory                  = "${var.memory}"
  output_directory        = "${var.build_directory}/packer-${var.template}-virtualbox"
  shutdown_command        = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "10000s"
  ssh_username            = "vagrant"
  vboxmanage              = [
    ["modifyvm", "{{ .Name }}", "--clipboard-mode", "bidirectional"],
    ["modifyvm", "{{ .Name }}", "--graphicscontroller", "vmsvga"],
    ["modifyvm", "{{ .Name }}", "--accelerate3d", "on"],
    ["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"],
    ["storagectl", "{{ .Name }}", "--name", "IDE Controller", "--remove"],
    // ["storageattach", "{{ .Name }}", "--storagectl", "SATA Controller", "--port", "1", "--device", "0", "--type", "dvddrive", "--medium", "emptydrive"],
  ]
  virtualbox_version_file = ".vbox_version"
  vm_name                 = "${var.template}"
}

source "vmware-iso" "rocky-9" {
  boot_command         = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.ks_path}<enter><wait>"]
  boot_wait            = "10s"
  cpus                 = "${var.cpus}"
  disk_adapter_type    = "pvscsi"
  disk_size            = "${var.disk_size}"
  guest_os_type        = "centos-64"
  headless             = "${var.headless}"
  http_directory       = "${local.http_directory}"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory               = "${var.memory}"
  network_adapter_type = "VMXNET3"
  output_directory     = "${var.build_directory}/packer-${var.template}-vmware"
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "10000s"
  ssh_username         = "vagrant"
  vm_name              = "${var.template}"
  vmx_data = {
    "cpuid.coresPerSocket" = "1"
    "disk.EnableUUID"      = "TRUE"
    "virtualHW.version"    = "13"
  }
  // vmx_remove_ethernet_interfaces = "${var.vmx_remove_ethernet_interfaces}"
}

source "vsphere-iso" "rocky-9" {
  boot_command         = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.ks_path}<enter><wait>"]
  boot_wait            = "10s"
  convert_to_template  = true
  CPUs                 = "${var.cpus}"
  // disk_adapter_type    = "pvscsi"
  storage {
      disk_size = "${var.disk_size}"
      disk_thin_provisioned = true
  }
  guest_os_type        = "centos-64"
  host                 = "${var.vmware_center_esxi_host}"
  // headless             = "${var.headless}"
  http_directory       = "${local.http_directory}"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  RAM                  = "${var.memory}"
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "10000s"
  ssh_username         = "vagrant"
  vm_name              = "${var.template}"
  vcenter_server       = "${var.vmware_center_host}"
  username             = "${var.vmware_center_username}"
  password             = "${var.vmware_center_password}"
  insecure_connection  = false
  datacenter           = "${var.vmware_center_datacenter}"
  datastore            = "${var.vmware_center_datastore}"
  network_adapters {
      network = "${var.vmware_center_vm_network}"
      network_card = "vmxnet3"
  }
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = [
    "source.hyperv-iso.rocky-9",
    "source.parallels-iso.rocky-9",
    "source.qemu.rocky-9",
    "source.virtualbox-iso.rocky-9",
    "source.vmware-iso.rocky-9",
    "source.vsphere-iso.rocky-9"
  ]


  provisioner "ansible" {
    playbook_file = "./ansible_provisioning/playbook.yaml"
    galaxy_file = "./ansible_provisioning/requirements.yaml"
    roles_path = "./ansible_provisioning/roles"
    galaxy_force_install = true
    user            = "vagrant"
    use_proxy       = false
    extra_arguments = [
      // "-v",
      "-e", "ansible_ssh_password=vagrant"
    ]
  }

  post-processors {

    post-processor "vagrant" {
      except = ["vsphere-iso.rocky-9"]
      output = "${var.output_directory}/${ var.vagrant_box }.${ replace(replace(replace(source.type, "-iso", ""), "hyper-v", "hyperv"), "vmware", "vmware_desktop") }.box"
    }

    # Once box has been created, upload it to Artifactory
    post-processor "shell-local" {
      except = ["vsphere-iso.rocky-9"]
      command = join(" ", [
        "jf rt upload",
        "--target-props \"box_name=${ var.vagrant_box };box_provider=${replace(replace(replace(source.type, "-iso", ""), "hyper-v", "hyperv"), "vmware", "vmware_desktop")};box_version=${ formatdate("YYYYMMDD", timestamp()) }.0\"",
        "--retries 10",
        "--access-token ${ var.artifactory_api_key }",
        "--user ${ var.artifactory_username }",
        "--url \"https://artifactory.ccdc.cam.ac.uk/artifactory\"",
        "${var.output_directory}/${var.vagrant_box}.${replace(replace(replace(source.type, "-iso", ""), "hyper-v", "hyperv"), "vmware", "vmware_desktop")}.box",
        "ccdc-vagrant-repo/${var.vagrant_box}.${formatdate("YYYYMMDD", timestamp())}.0.${replace(replace(replace(source.type, "-iso", ""), "hyper-v", "hyperv"), "vmware", "vmware_desktop")}.box"
      ])
    }
  }
}
