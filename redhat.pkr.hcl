packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
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

variable "cpus" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "disk_size" {
  type    = string
  default = "300000"
}

variable "headless" {
  type    = bool
  default = false
}

variable "hyperv_generation" {
  type    = string
  default = "1"
}

variable "hyperv_switch" {
  type    = string
  default = "${env("hyperv_switch")}"
}

variable "output_directory" {
  type    = string
  default = "${env("PWD")}/output/"
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

variable "vagrant_box" {
  type    = string
  default = "ccdc-basebox/redhat"
}

variable "port_min" {
  type    = number
  default = "49152"
}

variable "port_max" {
  type    = number
  default = "65535"
}

variable "iso_checksum" { type = string }
variable "iso_url" { type = string }
variable "kickstart_file" { type = string }
variable "vmware_guest_os_type" { type = string }
variable "vsphere_guest_os_type" { type = string }
variable "vsphere_name" { type = string }

locals {
  http_directory  = "${path.root}/http"
}

source "hyperv-iso" "redhat" {
  boot_command         = ["<wait5><tab> inst.text inst.ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
  boot_wait            = "10s"
  cpus                 = "${var.cpus}"
  disk_size            = "${var.disk_size}"
  floppy_files         = ["${local.http_directory}/${var.kickstart_file}"]
  generation           = "${var.hyperv_generation}"
  guest_additions_mode = "disable"
  http_directory       = "${local.http_directory}"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  output_directory     = "${var.output_directory}"
  memory               = "${var.memory}"
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "10000s"
  ssh_username         = "vagrant"
  switch_name          = "${var.hyperv_switch}"
  vm_name              = "${var.vsphere_name}-${formatdate("YYYYMMDD", timestamp())}"
}

source "vmware-iso" "redhat" {
  boot_command         = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.kickstart_file}<enter><wait>"]
  boot_wait            = "10s"
  cpus                 = "${var.cpus}"
  disk_adapter_type    = "pvscsi"
  disk_size            = "${var.disk_size}"
  guest_os_type        = "${var.vmware_guest_os_type}"
  headless             = "${var.headless}"
  http_directory       = "${local.http_directory}"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.memory}"
  network_adapter_type = "VMXNET3"
  output_directory     = "${var.output_directory}"
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
  // vmx_remove_ethernet_interfaces = "${var.vmx_remove_ethernet_interfaces}"
}

source "vsphere-iso" "redhat" {
  boot_command         = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.kickstart_file}<enter><wait>"]
  boot_wait            = "10s"
  convert_to_template  = true
  CPUs                 = "${var.cpus}"
  // disk_adapter_type    = "pvscsi"
  storage {
      disk_size = "${var.disk_size}"
      disk_thin_provisioned = true
  }
  guest_os_type        = "${var.vsphere_guest_os_type}"
  host                 = "${var.vmware_center_esxi_host}"
  // headless             = "${var.headless}"
  http_port_max        = "${var.port_max}"
  http_port_min        = "${var.port_min}"
  http_directory       = "${local.http_directory}"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  RAM                  = "${var.memory}"
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "10000s"
  ssh_username         = "vagrant"
  vm_name              = "${var.vsphere_name}-${formatdate("YYYYMMDD", timestamp())}"
  vcenter_server       = "${var.vmware_center_host}"
  username             = "${var.vmware_center_username}"
  password             = "${var.vmware_center_password}"
  insecure_connection  = false
  datacenter           = "${var.vmware_center_datacenter}"
  datastore            = "${var.vmware_center_datastore}"
  cluster              = "${var.vmware_center_cluster_name}"
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
    // "source.hyperv-iso.redhat",
    "source.vmware-iso.redhat",
    "source.vsphere-iso.redhat"
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
      except = ["vsphere-iso.redhat"]
      output = "${var.output_directory}/${ var.vagrant_box }.${ replace(replace(replace(source.type, "-iso", ""), "hyper-v", "hyperv"), "vmware", "vmware_desktop") }.box"
    }

    # Once box has been created, upload it to Artifactory
    post-processor "shell-local" {
      except = ["vsphere-iso.redhat"]
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
