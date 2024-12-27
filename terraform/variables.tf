variable "ibmcloud_api_key" {
  description = "API de IBM"
  type        = string
}

variable "region" {
  description = "Región"
  type        = string
}

variable "rg_id" {
  description = "ID del grupo de recursos"
  type        = string
}

variable "zone" {
  description = "Zona"
  type        = string
}

variable "vpc_id" {
  description = "ID de la red del cluster"
  type        = string
}