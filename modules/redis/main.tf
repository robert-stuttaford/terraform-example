resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "default-redis-subnet-group"
  subnet_ids = ["${var.subnet_group_ids}"]
}

resource "aws_elasticache_cluster" "redis" {
  engine               = "redis"
  port                 = "6379"
  parameter_group_name = "default.redis2.8"
  subnet_group_name    = "${aws_elasticache_subnet_group.redis_subnet.name}"
  cluster_id           = "${var.cluster_id}"
  node_type            = "${var.node_type}"
  num_cache_nodes      = "1"
  availability_zones   = ["${var.availability_zones[0]}"]
  security_group_ids   = ["${var.security_group_ids}"]
}

resource "aws_route53_record" "redis_subdomain" {
  zone_id = "${var.route53_public_zone_id}"
  name    = "${var.cluster_id}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_elasticache_cluster.redis.cache_nodes.0.address}"]
}
