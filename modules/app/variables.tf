variable "environment" {}

variable "app_name" {}

variable "app_nice_name" {}

variable "aws_account_id" {}

variable "aws_region" {}

variable "availability_zones" {
  type = "list"
}

variable "system_name" {}

variable "ami" {}

variable "instance_role_arn" {}

variable "instance_profile" {}

variable "security_group_ids" {
  type = "list"
}

variable "subnet_group_ids" {
  type = "list"
}

variable "instance_type" {
  default = "c4.large"
}

variable "min_size" {
  default = "1"
}

variable "desired_capacity" {
  default = "1"
}

variable "max_size" {
  default = "1"
}

variable "key_name" {}

variable "ansible_playbooks" {}
