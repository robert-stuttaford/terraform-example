# environment-specific variables
variable "aws_account_id" {}

variable "aws_profile" {}

variable "environment" {}

variable "system_name" {}

provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

# datadog
variable "datadog_integration_id" {}

# EC2: VPC
variable "cidr" {}

variable "public_ranges" {
  type = "list"
}

variable "private_ranges" {
  type = "list"
}

# Route53
variable "route53_public_zone_id" {}

variable "domain" {}

variable "acm_arn" {}

# EC2
variable "base_ami" {}

variable "key_name" {}

# datomic
variable "datomic_instance_count" {}

variable "datomic_instance_type" {}

variable "transactor_memory_index_max" {}

variable "transactor_memory_index_threshold" {}

variable "transactor_object_cache_max" {}

variable "transactor_xmx" {}

variable "dynamo_read_capacity" {}

variable "dynamo_write_capacity" {}

# backup
variable "backup_instance_type" {}

variable "backup_instance_count" {}

# memcached
variable "memcached_instance_type" {}

# redis
variable "redis_instance_type" {}

# bastion
variable "bastion_instance_type" {}

# c2
variable "c2_instance_type" {}

variable "c2_min_size" {}

variable "c2_desired_capacity" {}

variable "c2_max_size" {}

variable "c2_xmx" {}

variable "c2_memory_index_max" {}

variable "c2_object_cache_max" {}

# chat
variable "chat_instance_type" {}

variable "chat_min_size" {}

variable "chat_desired_capacity" {}

variable "chat_max_size" {}

variable "chat_xmx" {}

variable "chat_memory_index_max" {}

variable "chat_object_cache_max" {}

# highstorm
variable "highstorm_instance_type" {}

variable "highstorm_min_size" {}

variable "highstorm_desired_capacity" {}

variable "highstorm_max_size" {}

variable "highstorm_xmx" {}

variable "highstorm_memory_index_max" {}

variable "highstorm_object_cache_max" {}

# zookeeper
variable "zookeeper_instance_type" {}

variable "zookeeper_min_size" {}

variable "zookeeper_desired_capacity" {}

variable "zookeeper_max_size" {}
