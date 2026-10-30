variable "iso_file" {
  type    = string
  default = ""
}

variable "kickstart_file" {
  type = string
}

variable "insecure_skip_tls_verify" {
  type    = bool
  default = false
}

variable "token" {
  type      = string
  sensitive = true
  default   = env("PROXMOX_TOKEN")
}

variable "node_name" {
  type    = string
  default = "pve"
}

variable "proxmox_url" {
  type    = string
  default = env("PROXMOX_URL")
}

variable "username" {
  type    = string
  default = env("PROXMOX_USERNAME")
}


variable "proxmox_name" {
  type    = string
  default = "ccdc-basebox-rocky-template"
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "iso_storage_pool" {
  type    = string
  default = "local"
}

variable "network_bridge" {
  type    = string
  default = "vmbr1"
}

variable "cpus" {
  type    = number
  default = 2
}

variable "ram_mb" {
  type    = number
  default = 4096
}

variable "disk_size" {
  type    = string
  default = "30G"
}

variable "disk_format" {
  type    = string
  default = "raw"
}

variable "iso_url" {
  type    = string
  default = ""
}

variable "iso_checksum" {
  type    = string
  default = ""
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
