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

module "vm" {
  source = "./modules/vm"
  rg_id  = var.rg_id
  zone   = var.zone
  region = var.region
}

# module "cluster" {
#   source = "./modules/cluster"
#   rg_id  = var.rg_id
#   zone   = var.zone
#   region = var.region
# }

resource "ibm_cr_namespace" "cr_namespace" {
  name              = "acajas-cr-namespace"
  resource_group_id = var.rg_id
}