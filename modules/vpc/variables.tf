variable "cidr" {}

variable "availability_zones" {
  type = "list"
}

variable "enable_dns_hostnames" {}

variable "enable_dns_support" {}

variable "ip_range" {}

variable "public_ranges" {
  type = "list"
}

variable "private_ranges" {
  type = "list"
}
