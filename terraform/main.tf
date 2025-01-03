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

module "networks" {
  source = "./modules/networks"
  rg_id  = var.rg_id
  zone   = var.zone
  region = var.region
  vpc_id = var.vpc_id
}

module "vm" {
  source    = "./modules/vm"
  rg_id     = var.rg_id
  zone      = var.zone
  region    = var.region
  vpc_id    = var.vpc_id
  id_subnet = module.networks.id_subnet
  id_sg     = module.networks.id_sg
  user_password = var.user_password
}

# module "cluster" {
#   source = "./modules/cluster"
#   rg_id  = var.rg_id
#   zone   = var.zone
#   region = var.region
# }

# resource "ibm_is_vpc" "vpc_vm" {
#   name           = "vpc-vm-acajas"
#   resource_group = var.rg_id
# }

# data "ibm_is_vpc" "vpc_cluster" {
#   name = "ez-ibm-openshift-vpc-dcp4"
#   resource_group = var.rg_id
# }

# resource "ibm_is_public_gateway" "public_gateway" {
#   name           = "acajas-vpc-vm-gateway"
#   vpc            = "r050-4368bf72-fe4a-4fb0-a7ff-baccf91a74a4"
#   zone           = "eu-es-1"
#   resource_group = var.rg_id
# }

# resource "ibm_is_floating_ip" "public_ip_vm" {
#   name           = "pip-vm-bd-acajas"
#   resource_group = var.rg_id
#   target         = ibm_is_instance.vm_bd.primary_network_interface.0.id
# }

# resource "ibm_is_vpc" "vpc_cluster" {
#   name           = "vpc-cluster-acajas"
#   resource_group = var.rg_id
# }

# resource "ibm_is_subnet" "subnet_cluster" {
#   name            = "subnet-cluster-acajas"
#   vpc             = ibm_is_vpc.vpc_cluster.id
#   resource_group  = var.rg_id
#   zone            = var.zone
#   ipv4_cidr_block = "10.242.0.0/24"
#   public_gateway = ibm_is_public_gateway.public_gateway_cluster.id
# }

# resource "ibm_resource_instance" "cos_instance" {
#   name              = "acajas-cos-instance"
#   service           = "cloud-object-storage"
#   plan              = "standard"
#   location          = "global"
#   resource_group_id = var.rg_id
# }

# resource "ibm_container_vpc_cluster" "cluster" {
#   name              = "acajas-vpc-cluster"
#   vpc_id            = ibm_is_vpc.vpc_cluster.id
#   kube_version      = "4.16.23_openshift"
#   flavor            = "bx2.4x16"
#   worker_count      = "2"
#   cos_instance_crn  = ibm_resource_instance.cos_instance.id
#   resource_group_id = var.rg_id
#   zones {
#     subnet_id = ibm_is_subnet.subnet_cluster.id
#     name      = var.zone
#   }
# }

# resource "ibm_is_security_group" "sg_cluster" {
#   name           = "sg-cluster-acajas"
#   vpc            = ibm_is_vpc.vpc_cluster.id
#   resource_group = var.rg_id
# }

# resource "ibm_is_security_group_rule" "internet_cluster" {
#   direction = "outbound"
#   remote    = "0.0.0.0/0"
#   group     = ibm_is_security_group.sg_cluster.id
# }

# resource "ibm_is_public_gateway" "public_gateway_cluster" {
#   name           = "acajas-vpc-cluster-gateway"
#   vpc            = ibm_is_vpc.vpc_cluster.id
#   zone           = var.zone
#   resource_group = var.rg_id
# }
