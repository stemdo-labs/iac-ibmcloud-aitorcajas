terraform {
  required_version = ">=1.0.0, <2.0"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

resource "ibm_is_ssh_key" "ssh_key_vm" {
  name           = "acajas-ssh-key"
  public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/yhO+AunpWhYviv0+oBd+bwRx3cAN+0SzKEC9OKdiU7Q65A+U899NgitI1Qr4tsujo7/o8qw/w707wXn8tfeWB2pTiVUJ9qap90jtaMSDwPs9VYxWDFS687vxZ8k9N0Fmws0cg8qxdhoFJJU0OcjI0mQLZmFohr1el9ZEdxW+NWDfWy22e70DIlVO4oqv05OUV8yXZDFeOxVGxWAEJt0UsQGoup8m1cSEOkbrqnmrxDD93/sYBDMHf6aemoY9bCu9tJJGNg/hAt4pPzmtz/iVgoBHLOhPIintL5xD6DU304dkvY4y7eoNorMW5BzOdxRwYlb3fibYITQv5dJALPaygEmqEOWDFlNyWbHmcM5RsjrVnRvD19sS+ZPVucqAzomp9k83Fvm0csBxObf0QiYLJuIG66a7q1Pfamj6izVG4Cc9jrTwllQdLqv3Nri9pCBvuueDNWm8B8mJp4bWYaNuWFr9PnKJ8XWU+3puoi+9SFxKoXyU+ql1C9sXiWGKHsU="
  resource_group = var.rg_id
}

resource "ibm_is_instance" "vm_bd" {
  name           = "vm-bd-acajas"
  image          = "r050-8bddef68-ebaf-481f-a87e-a526f159b192"
  profile        = "bx2-2x8"
  vpc            = var.vpc_id
  zone           = var.zone
  resource_group = var.rg_id

  primary_network_interface {
    subnet            = var.id_subnet
    allow_ip_spoofing = true
    security_groups   = [var.id_sg]
    primary_ip {
      auto_delete = false
      address     = "10.251.1.6"
    }
  }

  keys = [ibm_is_ssh_key.ssh_key_vm.id]

  user_data = <<-EOF
   #!/bin/bash
   set -e
   USERNAME="acajasbd"
   USER_HOME="/home/$USERNAME"
   useradd -m -s /bin/bash "$USERNAME"
   echo "$USERNAME:${var.user_password}" | chpasswd
   usermod -aG sudo "$USERNAME"
   EOF
}

resource "ibm_cr_namespace" "cr_namespace" {
  name              = "acajas-cr"
  resource_group_id = var.rg_id
}