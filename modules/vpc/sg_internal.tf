resource "aws_security_group" "internal_inbound" {
  name        = "internal_inbound"
  description = "Allow access to apps on internal subnets from internal addresses"
  vpc_id      = "${aws_vpc.cgn.id}"

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  # http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  # exhibitor
  ingress {
    from_port   = 8181
    to_port     = 8181
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  # memcached
  ingress {
    from_port   = 11211
    to_port     = 11211
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  # redis
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  # datomic transactor
  ingress {
    from_port   = 4334
    to_port     = 4334
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  # aeron
  ingress {
    from_port   = 40200
    to_port     = 40200
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  # zookeeper
  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  ingress {
    from_port   = 2888
    to_port     = 2888
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  ingress {
    from_port   = 3888
    to_port     = 3888
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  # statsd
  ingress {
    from_port   = 2185
    to_port     = 2185
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  # icmp
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "internal_inbound"
  }
}
