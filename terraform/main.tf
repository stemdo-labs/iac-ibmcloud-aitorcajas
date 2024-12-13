terraform {
  required_version = ">=1.0.0, <2.0"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

resource "ibm_is_vpc" "vpc_vm" {
  name           = "vpc-vm-acajas"
  resource_group = var.rg_id
}

resource "ibm_is_subnet" "subnet_vm" {
  name            = "subnet-vm-acajas"
  vpc             = ibm_is_vpc.vpc_vm.id
  resource_group = var.rg_id
  zone            = var.zone
  ipv4_cidr_block = "10.0.1.0/24"
}

resource "ibm_is_instance" "vm_bd" {
  name           = "vm-bd-acajas"
  image          = "r006-21d636c2-eacf-4c31-9cc8-c7335966f4e3"
  profile        = "bx2-1x4"
  vpc            = ibm_is_vpc.vpc_vm.id
  zone           = var.zone
  resource_group = var.rg_id

  primary_network_interface {
    subnet            = ibm_is_subnet.subnet_vm.id
    allow_ip_spoofing = true
    primary_ip {
      auto_delete = false
      address     = "10.0.1.4"
    }
  }
}

resource "ibm_is_floating_ip" "public_ip_vm" {
  name = "pip-vm-bd-acajas"
  resource_group = var.rg_id
  target = ibm_is_instance.vm_bd.primary_network_interface.0.id
}