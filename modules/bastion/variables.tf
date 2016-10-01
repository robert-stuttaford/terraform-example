variable "ami" {}

variable "instance_type" {}

variable "iam_instance_profile" {}

variable "availability_zones" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "bastion_inbound_id" {}

variable "route53_public_zone_id" {}

variable "route53_sub_domain" {}

variable "key_name" {}
