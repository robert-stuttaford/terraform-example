# aws basics
variable "aws_region" {
  default = "us-west-2"
}

variable "master_aws_account_id" {
  default = "xxx"
}

variable "availability_zones" {
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# datadog
variable "datadog_api_key" {
  default = "xxx"
}

# Terraform State
variable "terraform_state_bucket" {
  default = "cgn-terraform"
}

variable "master_state_file" {
  default = "master/terraform.tfstate"
}

# circle ci
variable "circleci_api_token" {
  default = "xxx"
}

variable "master_circleci_access_key" {
  default = "xxx"
}

variable "master_circleci_access_secret" {
  default = "xxx"
}

# EC2
variable "enable_dns_hostnames" {
  default = "true"
}

variable "enable_dns_support" {
  default = "true"
}

variable "ip_range" {
  default = "10.0.0.0/12"
}

# datomic
variable "datomic_license" {
  default = "xxx"
}

variable "datomic_license_user" {
  default = "xxx"
}

variable "datomic_license_password" {
  default = "xxx"
}

variable "datomic_version" {
  default = "0.9.5394"
}

# datomic databases
variable "primary_datomic_database" {
  default = "cognician"
}

# bastion
variable "bastion_sub_domain" {
  default = "b"
}

# backup
variable "backup_app_name" {
  default = "backup"
}

variable "backup_app_nice_name" {
  default = "Backup"
}

# c2
variable "c2_app_name" {
  default = "c2"
}

variable "c2_app_nice_name" {
  default = "C2"
}

variable "c2_sub_domain" {
  default = "www"
}

# chat
variable "chat_app_name" {
  default = "chat"
}

variable "chat_app_nice_name" {
  default = "Chat"
}

variable "chat_sub_domain" {
  default = "chat"
}

# highstorm
variable "highstorm_app_name" {
  default = "highstorm"
}

variable "highstorm_app_nice_name" {
  default = "Highstorm"
}

# zookeeper
variable "zookeeper_app_name" {
  default = "zookeeper"
}

variable "zookeeper_app_nice_name" {
  default = "Zookeeper"
}
