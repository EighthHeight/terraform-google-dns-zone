############
# GCP Project
############

variable "gcp_project_id" {
  type        = string
  description = "The ID of the project where this VPC will be created"
}

##########
# DNS Managed Zone
##########

variable "zone_domain_name" {
  type        = string
  description = "(Required) The DNS name of this managed zone, for instance 'example.com'"
}

variable "zone_name" {
  type        = string
  description = "Name of this manged zone. If not set a slug of the dns_name will be used."
  default     = null
}

locals {
  zone_name = var.zone_name == null ? "zone-${replace(var.zone_domain_name, ".", "-")}" : var.zone_name
}

variable "zone_description" {
  type        = string
  description = "Description of the managed hosted zone"
  default     = null
}

locals {
  zone_description = var.zone_description == null ? "Managed Zone for ${var.zone_domain_name}" : var.zone_description
}

variable "zone_labels" {
  type        = map(string)
  description = "Labels to place on the managed hosted zone"
  default     = {}
}

##########
# Parent DNS Delegation
##########

variable "parent_zone_project_id" {
  type        = string
  description = "ID of the project which own the parent zone where the delegation record needs to be created"
  default     = null
}

variable "parent_zone_name" {
  type        = string
  description = "Unique name of parent managed zone where the delegation record needs to be created"
  default     = null
}

locals {
  enable_parent_delegation = var.parent_zone_project_id == null || var.parent_zone_name == null ? false : true
}

##########
# Domain Level Records
##########

variable "domain_records" {
  type = list(object({
    type = string
    data = list(string)
    ttl  = number
  }))
  default = []
  nullable = false
}

variable "subdomain_records" {
  type = list(object({
    name = string
    type = string
    data = list(string)
    ttl  = number
  }))
  default = []
  nullable = false
}
