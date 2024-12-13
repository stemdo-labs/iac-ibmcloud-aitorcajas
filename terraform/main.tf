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
  resource_group  = var.rg_id
  zone            = var.zone
  ipv4_cidr_block = "10.242.0.0/24"
}

resource "ibm_security_group" "sg_vm" {
  name        = "sg-vm-acajas"
}

resource "ibm_security_group_rule" "allow_port_22" {
    direction = "ingress"
    protocol  = "tcp"
    port_range_min  = 22
    port_range_max  = 22
    remote_ip = "0.0.0.0/0"
    security_group_id = ibm_security_group.sg_vm.id
}

resource "ibm_is_instance" "vm_bd" {
  name           = "vm-bd-acajas"
  image          = "r018-941eb02e-ceb9-44c8-895b-b31d241f43b5"
  profile        = "bx2-2x8"
  vpc            = ibm_is_vpc.vpc_vm.id
  zone           = var.zone
  resource_group = var.rg_id

  primary_network_interface {
    subnet            = ibm_is_subnet.subnet_vm.id
    allow_ip_spoofing = true
    security_groups   = [ibm_security_group.sg_vm.id]
    primary_ip {
      auto_delete = false
      address     = "10.242.0.4"
    }
  }
}

resource "ibm_is_floating_ip" "public_ip_vm" {
  name           = "pip-vm-bd-acajas"
  resource_group = var.rg_id
  target         = ibm_is_instance.vm_bd.primary_network_interface.0.id
}
