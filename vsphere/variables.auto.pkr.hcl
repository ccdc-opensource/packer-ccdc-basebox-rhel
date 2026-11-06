variable "cpus" {
  type    = number
  default = 1
}

variable "memory" {
  type    = number
  default = 1024
}

variable "disk_size" {
  type    = number
  default = 300000
}

variable "headless" {
  type    = bool
  default = false
}

variable "output_directory" {
  type    = string
  default = "${env("PWD")}/output/"
}

variable "vagrant_box" {
  type    = string
  default = "ccdc-basebox/redhat"
}

variable "ipaddress" {
  type    = string
  default = "{{ .HTTPIP }}"
}

variable "vmware_center_cluster_name" {
  type    = string
  default = env("VMWARECENTER_CLUSTER_NAME")
}

variable "vmware_center_datacenter" {
  type    = string
  default = env("VMWARECENTER_DATACENTER")
}

variable "vmware_center_datastore" {
  type    = string
  default = env("VMWARECENTER_DATASTORE")
}

variable "vmware_center_esxi_host" {
  type    = string
  default = env("VMWARECENTER_ESXI_HOST")
}

variable "vmware_center_host" {
  type    = string
  default = env("VMWARECENTER_HOST")
}

variable "vmware_center_password" {
  type      = string
  sensitive = true
  default   = env("VMWARECENTER_PASSWORD")
}

variable "vmware_center_username" {
  type    = string
  default = env("VMWARECENTER_USERNAME")
}

variable "vmware_center_vm_network" {
  type    = string
  default = env("VMWARECENTER_VM_NETWORK")
}

variable "ansible_playbook_file" {
  type    = string
  default = "../ansible_provisioning/playbook.yaml"
}

variable "ansible_requirements_file" {
  type    = string
  default = "../ansible_provisioning/requirements.yaml"
}

variable "ansible_roles_path" {
  type    = string
  default = "../ansible_provisioning/roles"
}

variable "port_min" {
  type    = number
  default = 49152
}

variable "port_max" {
  type    = number
  default = 65535
}

variable "iso_checksum" { type = string }
variable "iso_url" { type = string }
variable "kickstart_file" { type = string }
variable "vmware_guest_os_type" { type = string }
variable "vsphere_guest_os_type" { type = string }
variable "vsphere_name" { type = string }
