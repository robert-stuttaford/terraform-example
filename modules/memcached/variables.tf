variable "node_count" {}

variable "cluster_id" {}

variable "node_type" {}

variable "availability_zones" {
  type = "list"
}

variable "subnet_group_ids" {
  type = "list"
}

variable "security_group_ids" {
  type = "list"
}

variable "route53_public_zone_id" {}
