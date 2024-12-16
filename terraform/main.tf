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

resource "ibm_is_security_group" "sg_vm" {
  name           = "sg-vm-acajas"
  vpc            = ibm_is_vpc.vpc_vm.id
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

resource "ibm_is_public_gateway" "public_gateway" {
  name           = "acajas-vpc-vm-gateway"
  vpc            = ibm_is_vpc.vpc_vm.id
  zone           = var.zone
  resource_group = var.rg_id
}

resource "ibm_is_ssh_key" "ssh_key_vm" {
  name           = "public-ssh-key"
  public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/yhO+AunpWhYviv0+oBd+bwRx3cAN+0SzKEC9OKdiU7Q65A+U899NgitI1Qr4tsujo7/o8qw/w707wXn8tfeWB2pTiVUJ9qap90jtaMSDwPs9VYxWDFS687vxZ8k9N0Fmws0cg8qxdhoFJJU0OcjI0mQLZmFohr1el9ZEdxW+NWDfWy22e70DIlVO4oqv05OUV8yXZDFeOxVGxWAEJt0UsQGoup8m1cSEOkbrqnmrxDD93/sYBDMHf6aemoY9bCu9tJJGNg/hAt4pPzmtz/iVgoBHLOhPIintL5xD6DU304dkvY4y7eoNorMW5BzOdxRwYlb3fibYITQv5dJALPaygEmqEOWDFlNyWbHmcM5RsjrVnRvD19sS+ZPVucqAzomp9k83Fvm0csBxObf0QiYLJuIG66a7q1Pfamj6izVG4Cc9jrTwllQdLqv3Nri9pCBvuueDNWm8B8mJp4bWYaNuWFr9PnKJ8XWU+3puoi+9SFxKoXyU+ql1C9sXiWGKHsU="
  resource_group = var.rg_id
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
    security_groups   = [ibm_is_security_group.sg_vm.id]
    primary_ip {
      auto_delete = false
      address     = "10.242.0.4"
    }
  }

  keys = [ibm_is_ssh_key.ssh_key_vm.id]
}

resource "ibm_is_floating_ip" "public_ip_vm" {
  name           = "pip-vm-bd-acajas"
  resource_group = var.rg_id
  target         = ibm_is_instance.vm_bd.primary_network_interface.0.id
}

resource "ibm_is_vpc" "vpc_cluster" {
  name           = "vpc-cluster-acajas"
  resource_group = var.rg_id
}

resource "ibm_is_subnet" "subnet_cluster" {
  name            = "subnet-cluster-acajas"
  vpc             = ibm_is_vpc.vpc_cluster.id
  resource_group  = var.rg_id
  zone            = var.zone
  ipv4_cidr_block = "10.242.0.0/24"
}

resource "ibm_resource_instance" "cos_instance" {
  name     = "acajas-cos-instance"
  service  = "cloud-object-storage"
  plan     = "lite"
  location = var.location
}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "acajas-vpc-cluster"
  vpc_id            = ibm_is_vpc.vpc_cluster.id
  kube_version      = "4.3_openshift"
  flavor            = "bx2.4x16"
  worker_count      = "1"
  cos_instance_crn  = ibm_resource_instance.cos_instance.id
  resource_group_id = var.rg_id
  zones {
      subnet_id = ibm_is_subnet.subnet_cluster.id
      name      = var.zone
    }
}