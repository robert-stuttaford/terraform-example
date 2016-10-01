output "circleci_api_token" {
  value = "${var.circleci_api_token}"
}

output "circleci_access_key" {
  value = "${module.staging_codedeploy.circleci_access_key}"
}

output "circleci_access_secret" {
  value = "${module.staging_codedeploy.circleci_access_secret}"
}

output "ansible_playbooks" {
  value = "${module.staging_codedeploy.ansible_playbooks}"
}

output "aws_region" {
  value = "${var.aws_region}"
}

output "cognician_environment" {
  value = "${var.environment}"
}

output "root_domain" {
  value = "${var.domain}"
}

output "c2_domain" {
  value = "${var.c2_sub_domain}.${var.domain}"
}

output "c3_domain" {
  value = "${var.chat_sub_domain}.${var.domain}"
}

# memcached

output "memcached_uri" {
  value = "${module.staging_memcached.memcached_uri}"
}

# datomic

output "datomic_license_user" {
  value = "${var.datomic_license_user}"
}

output "datomic_license_password" {
  value = "${var.datomic_license_password}"
}

output "datomic_version" {
  value = "${var.datomic_version}"
}

output "primary_database_uri" {
  value = "datomic:ddb://${var.aws_region}/${module.staging_datomic.dynamodb_table_name}/${var.primary_datomic_database}"
}

# backups

output "database_backup_source_uri" {
  value = "datomic:ddb://${var.aws_region}/${module.staging_datomic.dynamodb_table_name}/${var.primary_datomic_database}"
}

output "database_backup_target_uri" {
  value = "s3://${aws_s3_bucket.backups.bucket}/${var.primary_datomic_database}"
}

# s3

output "ci_bucket" {
  value = "${module.staging_codedeploy.ci_bucket}"
}

output "exhibitor_control_bucket" {
  value = "${aws_s3_bucket.exhibitor.bucket}"
}

output "static_media_bucket" {
  value = "${aws_s3_bucket.static_media.bucket}"
}

output "cog_media_bucket" {
  value = "${aws_s3_bucket.cog_media.bucket}"
}

output "user_media_bucket" {
  value = "${aws_s3_bucket.user_media.bucket}"
}

output "generated_media_bucket" {
  value = "${aws_s3_bucket.generated_media.bucket}"
}

# c2

output "c2_xmx" {
  value = "${var.c2_xmx}"
}

output "c2_memory_index_max" {
  value = "${var.c2_memory_index_max}"
}

output "c2_object_cache_max" {
  value = "${var.c2_object_cache_max}"
}

# chat

output "chat_xmx" {
  value = "${var.chat_xmx}"
}

output "chat_memory_index_max" {
  value = "${var.chat_memory_index_max}"
}

output "chat_object_cache_max" {
  value = "${var.chat_object_cache_max}"
}

# highstorm

output "highstorm_xmx" {
  value = "${var.highstorm_xmx}"
}

output "highstorm_memory_index_max" {
  value = "${var.highstorm_memory_index_max}"
}

output "highstorm_object_cache_max" {
  value = "${var.highstorm_object_cache_max}"
}
