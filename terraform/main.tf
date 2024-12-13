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

resource "ibm_is_vpc_routing_table" "routing_table_vm" {
  name = "routing-table-vm-acajas"
  vpc  = ibm_is_vpc.vpc_vm.id
}

resource "ibm_is_subnet" "subnet_vm" {
  name            = "subnet-vm-acajas"
  vpc             = ibm_is_vpc.vpc_vm.id
  zone            = var.region
  ipv4_cidr_block = "10.0.1.0/24"
  routing_table   = ibm_is_vpc_routing_table.routing_table_vm.routing_table
}

resource "ibm_is_floating_ip" "public_ip_vm" {
  name = "pip-vm-bd-acajas"
  zone = var.region
}

resource "ibm_is_virtual_network_interface" "vni_vm_bd" {
  name                      = "vni-bd-vm-acajas"
  allow_ip_spoofing         = false
  enable_infrastructure_nat = true

  primary_ip {
    auto_delete = false
    address     = "10.0.1.4"
  }
  subnet = ibm_is_subnet.subnet_vm.id
}

resource "ibm_is_instance" "vm_bd" {
  name    = "vm-acajas-bd"
  zone    = var.region
  profile = "bx2-1x4"
  image   = "ibm-ubuntu-20-04-3-minimal-amd64-2"

  primary_network_attachment {
    name = "primary-att"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.vni_vm_bd.id
    }
  }

  boot_volume {
    name    = "volume-vm-bd-acajas"
    profile = "general-purpose"
  }
}
