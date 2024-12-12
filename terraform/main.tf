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
  name = var.vpc_name
  resource_group = var.rg_id
}

resource "ibm_is_vpc_routing_table" "routing_table" {
  name = "example-routing-table"
  vpc  =  ibm_is_vpc.vpc.id
}

resource "ibm_is_subnet" "subnet" {
  name            = var.subnet_name
  vpc             = ibm_is_vpc.vpc.id
  zone            = var.region
  ipv4_cidr_block = "10.0.1.0/24"
  routing_table   = ibm_is_vpc_routing_table.routing_table.routing_table
}