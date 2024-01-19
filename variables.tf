
# AWS Resources variables
variable "vpc_region" {
  description = "The name of the AWS region to set up a network within"
  default = "eu-west-1"
}
# variable "vpc_id" {
#   description = "The VPC ID"
# }


# GCP Resources variables
variable "gcp_region" {
  description = "The name of the GCP region to set up a network within"
  default = "europe-west1"
}
variable "gcp_project" {
  description = "The GCP project to set up a network within"
}
variable "nodes" {
    description = "Number of GCP instances"
    default = 1
}
variable "owner" {
    description = "Owner name for tagging and access"
    default = "dcanadillas"
}
variable "machine" {
    description = "GCP instance type"
    default = "n2-standard-2"
}
variable "cluster" {
    description = "Cluster name for the nodes"
}
variable "gcp_zone" {
    description = "GCP zone for the nodes"
    default = "europe-west1-b"
}


# HCP Resources variables
variable "hvn_id" {
  description = "The HVN ID"
  default = "hvn"
}
variable "consul_cluster" {
  description = "The Consul cluster id in HCP"
  default = ""
}
variable "vault_cluster" {
  description = "The Vault cluster id in HCP"
  default = ""
}