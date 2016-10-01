resource "aws_elasticache_subnet_group" "memcached_subnet" {
  name       = "default-memcached-subnet-group"
  subnet_ids = ["${var.subnet_group_ids}"]
}

resource "aws_elasticache_cluster" "memcached" {
  engine               = "memcached"
  port                 = "11211"
  parameter_group_name = "default.memcached1.4"
  subnet_group_name    = "${aws_elasticache_subnet_group.memcached_subnet.name}"
  cluster_id           = "${var.cluster_id}"
  node_type            = "${var.node_type}"
  num_cache_nodes      = "${var.node_count}"
  availability_zones   = "${var.availability_zones}"
  security_group_ids   = ["${var.security_group_ids}"]
}
