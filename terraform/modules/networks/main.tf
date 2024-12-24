terraform {
  required_version = ">=1.0.0, <2.0"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

resource "ibm_is_subnet" "subnet_vm" {
  name            = "subnet-vm-acajas"
  vpc             = var.vpc_id
  resource_group  = var.rg_id
  zone            = var.zone
  ipv4_cidr_block = "10.251.1.0/24"
}

resource "ibm_is_security_group" "sg_vm" {
  name           = "sg-vm-acajas"
  vpc            = var.vpc_id
  resource_group = var.rg_id
}

resource "ibm_is_security_group_rule" "internet" {
  direction = "outbound"
  remote    = "0.0.0.0/0"
  group     = ibm_is_security_group.sg_vm.id
}

resource "ibm_is_security_group_rule" "ssh" {
  direction = "inbound"
  remote    = "0.0.0.0/0"
  group     = ibm_is_security_group.sg_vm.id

  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "ping" {
  direction = "inbound"
  remote    = "0.0.0.0/0"
  group     = ibm_is_security_group.sg_vm.id

  icmp {
    code = 0
    type = 8
  }
}

output "id_subnet" {
  value = ibm_is_subnet.subnet_vm.id
}

output "id_sg" {
  value = ibm_is_security_group.sg_vm.id
}