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

resource "ibm_is_vpc" "vpc" {
  name           = "vpc-vm-acajas"
  resource_group = var.rg_id
}

resource "ibm_is_vpc_routing_table" "routing_table" {
  name = "routing-table-vm-acajas"
  vpc  = ibm_is_vpc.vpc.id
}

resource "ibm_is_subnet" "subnet" {
  name            = "subnet-vm-acajas"
  vpc             = ibm_is_vpc.vpc.id
  zone            = var.region
  ipv4_cidr_block = "10.0.1.0/24"
  routing_table   = ibm_is_vpc_routing_table.routing_table.routing_table
}

resource "ibm_is_floating_ip" "public_ip" {
  name = "pip-vm-bd-acajas"
  zone = var.region
}

resource "ibm_is_instance" "vm" {
  name    = "vm-acajas-bd"
  vpc     = ibm_is_vpc.vpc.id
  zone    = var.region
  profile = "bx2-1x4"
  image   = "ibm-ubuntu-20-04-3-minimal-amd64-2"
  
  primary_network_interface {
    subnet          = ibm_is_subnet.subnet.id
    floating_ip     = ibm_is_floating_ip.public_ip.id
    security_groups = []
  }

  boot_volume {
    name = "volume-vm-bd-acajas"
    profile = "general-purpose"
    capacity = 20
  }
}