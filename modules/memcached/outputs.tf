output "memcached_uri" {
  value = "${aws_elasticache_cluster.memcached.configuration_endpoint}"
}
