resource "aws_security_group" "bastion_inbound" {
  name        = "bastion_inbound"
  description = "Allow SSH to Bastion host from approved ranges"
  vpc_id      = "${aws_vpc.cgn.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "bastion_inbound"
  }
}

resource "aws_security_group" "bastion_outbound" {
  name        = "bastion_outbound"
  description = "Allow SSH from Bastion host(s)"
  vpc_id      = "${aws_vpc.cgn.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/12"]
  }

  tags {
    Name = "bastion_outbound"
  }
}
