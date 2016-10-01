module "staging_vpc" {
  source = "./modules/vpc"

  cidr               = "${var.cidr}"
  availability_zones = "${var.availability_zones}"

  public_ranges  = "${var.public_ranges}"
  private_ranges = "${var.private_ranges}"

  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  ip_range             = "${var.ip_range}"
}

module "staging_iam" {
  source         = "./modules/iam"
  system_name    = "${var.system_name}"
  aws_account_id = "${var.aws_account_id}"
}

module "staging_codedeploy" {
  source                = "./modules/codedeploy"
  system_name           = "${var.system_name}"
  aws_account_id        = "${var.aws_account_id}"
  master_aws_account_id = "${var.master_aws_account_id}"
  static_media_bucket   = "${aws_s3_bucket.static_media.bucket}"
}

module "staging_datadog" {
  source        = "./modules/datadog"
  shared_secret = "${var.datadog_integration_id}"
}

module "staging_memcached" {
  source                 = "./modules/memcached"
  node_count             = "${length(var.availability_zones)}"
  cluster_id             = "memcached-${var.environment}"
  node_type              = "${var.memcached_instance_type}"
  availability_zones     = "${var.availability_zones}"
  subnet_group_ids       = "${module.staging_vpc.private_subnets}"
  security_group_ids     = ["${module.staging_vpc.internal_inbound_id}"]
  route53_public_zone_id = "${var.route53_public_zone_id}"
}

module "staging_redis" {
  source                 = "./modules/redis"
  cluster_id             = "redis-${var.environment}"
  node_type              = "${var.redis_instance_type}"
  availability_zones     = "${var.availability_zones}"
  subnet_group_ids       = "${module.staging_vpc.private_subnets}"
  security_group_ids     = ["${module.staging_vpc.internal_inbound_id}"]
  route53_public_zone_id = "${var.route53_public_zone_id}"
}

module "staging_bastion" {
  source        = "./modules/bastion"
  ami           = "${var.base_ami}"
  instance_type = "${var.bastion_instance_type}"

  key_name = "${var.key_name}"

  iam_instance_profile = "${module.staging_iam.instance_profile}"
  availability_zones   = "${var.availability_zones}"

  public_subnet_ids  = "${module.staging_vpc.public_subnets}"
  bastion_inbound_id = "${module.staging_vpc.bastion_inbound_id}"

  route53_public_zone_id = "${var.route53_public_zone_id}"
  route53_sub_domain     = "${var.bastion_sub_domain}"
}

module "staging_backup" {
  source           = "./modules/app"
  environment      = "${var.environment}"
  app_name         = "${var.backup_app_name}"
  app_nice_name    = "${var.backup_app_nice_name}"
  aws_account_id   = "${var.aws_account_id}"
  aws_region       = "${var.aws_region}"
  ami              = "${var.base_ami}"
  instance_type    = "${var.backup_instance_type}"
  min_size         = "${var.backup_instance_count}"
  desired_capacity = "${var.backup_instance_count}"
  max_size         = "${var.backup_instance_count}"
  key_name         = "${var.key_name}"

  availability_zones = "${var.availability_zones}"
  system_name        = "${var.system_name}"
  instance_profile   = "${module.staging_iam.instance_profile}"
  instance_role_arn  = "${module.staging_iam.instance_role_arn}"
  security_group_ids = ["${module.staging_vpc.internal_inbound_id}"]
  subnet_group_ids   = "${module.staging_vpc.private_subnets}"

  ansible_playbooks = "${module.staging_codedeploy.ansible_playbooks}"
}

module "staging_datomic" {
  source                            = "./modules/datomic"
  environment                       = "${var.environment}"
  aws_account_id                    = "${var.aws_account_id}"
  aws_region                        = "${var.aws_region}"
  availability_zones                = "${var.availability_zones}"
  system_name                       = "${var.system_name}"
  peer_role                         = "${module.staging_iam.instance_role_name}"
  security_group_ids                = ["${module.staging_vpc.internal_inbound_id}"]
  subnet_group_ids                  = "${module.staging_vpc.private_subnets}"
  instance_count                    = "${var.datomic_instance_count}"
  dynamo_write_capacity             = "${var.dynamo_write_capacity}"
  dynamo_read_capacity              = "${var.dynamo_read_capacity}"
  datomic_version                   = "${var.datomic_version}"
  datomic_license                   = "${var.datomic_license}"
  transactor_instance_type          = "${var.datomic_instance_type}"
  transactor_memory_index_max       = "${var.transactor_memory_index_max}"
  transactor_memory_index_threshold = "${var.transactor_memory_index_threshold}"
  transactor_object_cache_max       = "${var.transactor_object_cache_max}"
  transactor_xmx                    = "${var.transactor_xmx}"
  memcached_uri                     = "${module.staging_memcached.memcached_uri}"
  datadog_api_key                   = "${var.datadog_api_key}"
}

module "staging_c2" {
  source           = "./modules/web"
  environment      = "${var.environment}"
  app_name         = "${var.c2_app_name}"
  app_nice_name    = "${var.c2_app_nice_name}"
  aws_account_id   = "${var.aws_account_id}"
  aws_region       = "${var.aws_region}"
  ami              = "${var.base_ami}"
  instance_type    = "${var.c2_instance_type}"
  min_size         = "${var.c2_min_size}"
  desired_capacity = "${var.c2_desired_capacity}"
  max_size         = "${var.c2_max_size}"
  key_name         = "${var.key_name}"

  domain                 = "${var.domain}"
  route53_public_zone_id = "${var.route53_public_zone_id}"
  acm_arn                = "${var.acm_arn}"
  route53_sub_domain     = "${var.c2_sub_domain}"

  availability_zones = "${var.availability_zones}"
  system_name        = "${var.system_name}"
  instance_profile   = "${module.staging_iam.instance_profile}"
  instance_role_arn  = "${module.staging_iam.instance_role_arn}"
  security_group_ids = ["${module.staging_vpc.web_inbound_id}"]
  subnet_group_ids   = "${module.staging_vpc.public_subnets}"

  ansible_playbooks = "${module.staging_codedeploy.ansible_playbooks}"
}

module "staging_chat" {
  source           = "./modules/web_tcp"
  environment      = "${var.environment}"
  app_name         = "${var.chat_app_name}"
  app_nice_name    = "${var.chat_app_nice_name}"
  aws_account_id   = "${var.aws_account_id}"
  aws_region       = "${var.aws_region}"
  ami              = "${var.base_ami}"
  instance_type    = "${var.chat_instance_type}"
  min_size         = "${var.chat_min_size}"
  desired_capacity = "${var.chat_desired_capacity}"
  max_size         = "${var.chat_max_size}"
  key_name         = "${var.key_name}"

  domain                 = "${var.domain}"
  route53_public_zone_id = "${var.route53_public_zone_id}"
  acm_arn                = "${var.acm_arn}"
  route53_sub_domain     = "${var.chat_sub_domain}"

  availability_zones = "${var.availability_zones}"
  system_name        = "${var.system_name}"
  instance_profile   = "${module.staging_iam.instance_profile}"
  instance_role_arn  = "${module.staging_iam.instance_role_arn}"
  security_group_ids = ["${module.staging_vpc.web_inbound_id}"]
  subnet_group_ids   = "${module.staging_vpc.public_subnets}"

  ansible_playbooks = "${module.staging_codedeploy.ansible_playbooks}"
}

module "staging_highstorm" {
  source           = "./modules/app"
  environment      = "${var.environment}"
  app_name         = "${var.highstorm_app_name}"
  app_nice_name    = "${var.highstorm_app_nice_name}"
  aws_account_id   = "${var.aws_account_id}"
  aws_region       = "${var.aws_region}"
  ami              = "${var.base_ami}"
  instance_type    = "${var.highstorm_instance_type}"
  min_size         = "${var.highstorm_min_size}"
  desired_capacity = "${var.highstorm_desired_capacity}"
  max_size         = "${var.highstorm_max_size}"
  key_name         = "${var.key_name}"

  availability_zones = "${var.availability_zones}"
  system_name        = "${var.system_name}"
  instance_profile   = "${module.staging_iam.instance_profile}"
  instance_role_arn  = "${module.staging_iam.instance_role_arn}"
  security_group_ids = ["${module.staging_vpc.internal_inbound_id}"]
  subnet_group_ids   = "${module.staging_vpc.private_subnets}"

  ansible_playbooks = "${module.staging_codedeploy.ansible_playbooks}"
}

module "staging_zookeeper" {
  source           = "./modules/app"
  environment      = "${var.environment}"
  app_name         = "${var.zookeeper_app_name}"
  app_nice_name    = "${var.zookeeper_app_nice_name}"
  aws_account_id   = "${var.aws_account_id}"
  aws_region       = "${var.aws_region}"
  ami              = "${var.base_ami}"
  instance_type    = "${var.zookeeper_instance_type}"
  min_size         = "${var.zookeeper_min_size}"
  desired_capacity = "${var.zookeeper_desired_capacity}"
  max_size         = "${var.zookeeper_max_size}"
  key_name         = "${var.key_name}"

  availability_zones = "${var.availability_zones}"
  system_name        = "${var.system_name}"
  instance_profile   = "${module.staging_iam.instance_profile}"
  instance_role_arn  = "${module.staging_iam.instance_role_arn}"
  security_group_ids = ["${module.staging_vpc.internal_inbound_id}"]
  subnet_group_ids   = "${module.staging_vpc.public_subnets}"

  ansible_playbooks = "${module.staging_codedeploy.ansible_playbooks}"
}
