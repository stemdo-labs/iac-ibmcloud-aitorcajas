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
  name              = "acajas-cos-instance"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = var.rg_id
}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "acajas-vpc-cluster"
  vpc_id            = ibm_is_vpc.vpc_cluster.id
  kube_version      = "4.16.23_openshift"
  flavor            = "bx2.4x16"
  worker_count      = "1"
  cos_instance_crn  = ibm_resource_instance.cos_instance.id
  resource_group_id = var.rg_id
  zones {
    subnet_id = ibm_is_subnet.subnet_cluster.id
    name      = var.zone
  }
}