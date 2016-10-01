resource "aws_instance" "bastion" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${var.iam_instance_profile}"
  availability_zone           = "${var.availability_zones[0]}"
  subnet_id                   = "${var.public_subnet_ids[0]}"
  vpc_security_group_ids      = ["${var.bastion_inbound_id}"]
  associate_public_ip_address = true
  key_name                    = "${var.key_name}"

  connection {
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /ops",
      "sudo chown -R ubuntu:ubuntu /ops",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/files/authorized_keys2"
    destination = "/ops/authorized_keys2"
  }

  provisioner "file" {
    source      = "${path.module}/files/sshd_config"
    destination = "/ops/sshd_config"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/provision.sh"
  }

  tags {
    Type = "Bastion"
  }
}

resource "aws_route53_record" "bastion_subdomain" {
  zone_id = "${var.route53_public_zone_id}"
  name    = "${var.route53_sub_domain}"
  type    = "A"
  ttl     = "60"
  records = ["${aws_instance.bastion.public_ip}"]
}
