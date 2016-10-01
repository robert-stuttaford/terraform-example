variable "environment" {}

variable "aws_account_id" {}

variable "aws_region" {}

variable "availability_zones" {
  type = "list"
}

variable "system_name" {}

variable "peer_role" {}

variable "security_group_ids" {
  type = "list"
}

variable "subnet_group_ids" {
  type = "list"
}

variable "transactor_instance_type" {
  default = "c3.large"
}

variable "instance_count" {
  default = "1"
}

variable "transactor_memory_index_max" {
  default = "512m"
}

variable "transactor_memory_index_threshold" {
  default = "32m"
}

variable "transactor_object_cache_max" {
  default = "1g"
}

variable "transactor_xmx" {
  default = "2625m"
}

variable "datomic_version" {
  default = "0.9.5394"
}

variable "dynamo_read_capacity" {
  default = "10"
}

variable "dynamo_write_capacity" {
  default = "10"
}

variable "datomic_license" {}

variable "transactor_instance_virtualization_type" {
  default = "hvm"
}

variable "transactor_java_opts" {
  default = ""
}

variable "cloudwatch_dimension" {
  default = "Datomic"
}

variable "memcached_uri" {}

variable "datadog_api_key" {}
