data "template_file" "user_data" {
  template = "${file("${path.module}/../_common/userdata.sh")}"

  vars {
    ansible_playbooks = "${var.ansible_playbooks}"
    playbook          = "${var.app_name}"
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix          = "${var.app_name}-"
  image_id             = "${var.ami}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${var.instance_profile}"
  security_groups      = ["${var.security_group_ids}"]
  key_name             = "${var.key_name}"
  user_data            = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_size = 20
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                  = "${var.app_name}"
  availability_zones    = "${var.availability_zones}"
  min_size              = "${var.min_size}"
  desired_capacity      = "${var.desired_capacity}"
  max_size              = "${var.max_size}"
  launch_configuration  = "${aws_launch_configuration.launch_configuration.name}"
  vpc_zone_identifier   = ["${var.subnet_group_ids}"]
  wait_for_elb_capacity = false
  load_balancers        = ["${aws_elb.load_balancer.name}"]

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Type"
    value               = "${var.app_nice_name}"
    propagate_at_launch = true
  }
}

resource "aws_codedeploy_app" "codedeploy_app" {
  name = "${var.app_nice_name}"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name              = "${aws_codedeploy_app.codedeploy_app.name}"
  deployment_group_name = "Default"
  service_role_arn      = "${var.instance_role_arn}"
  autoscaling_groups    = ["${aws_autoscaling_group.autoscaling_group.name}"]
}

resource "aws_elb" "load_balancer" {
  name            = "${var.app_name}-lb"
  subnets         = ["${var.subnet_group_ids}"]
  security_groups = ["${var.security_group_ids}"]
  idle_timeout    = 300

  listener {
    lb_port           = 80
    lb_protocol       = "TCP"
    instance_port     = 80
    instance_protocol = "TCP"
  }

  listener {
    lb_port            = 443
    lb_protocol        = "SSL"
    instance_port      = 443
    instance_protocol  = "TCP"
    ssl_certificate_id = "${var.acm_arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
    target              = "HTTP:3000/health-check"
  }
}

resource "aws_proxy_protocol_policy" "proxy_protocol_policy" {
  load_balancer  = "${aws_elb.load_balancer.name}"
  instance_ports = ["80", "443"]
}

resource "aws_s3_bucket" "elb_failover" {
  bucket        = "${var.route53_sub_domain}.${var.domain}"
  acl           = "public-read"
  force_destroy = true

  lifecycle {
    # prevent_destroy = true
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  policy = <<EOF
{
  "Statement": [
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${var.route53_sub_domain}.${var.domain}/*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

resource "aws_s3_bucket_object" "elb_failover_index_page" {
  bucket       = "${aws_s3_bucket.elb_failover.bucket}"
  key          = "index.html"
  source       = "${path.module}/../_common/elb_failover_index.html"
  etag         = "${md5(file("${path.module}/../_common/elb_failover_index.html"))}"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "elb_failover_error_page" {
  bucket       = "${aws_s3_bucket.elb_failover.bucket}"
  key          = "error.html"
  source       = "${path.module}/../_common/elb_failover_error.html"
  etag         = "${md5(file("${path.module}/../_common/elb_failover_error.html"))}"
  content_type = "text/html"
}

resource "aws_route53_health_check" "domain_health_check" {
  fqdn              = "${aws_elb.load_balancer.dns_name}"
  port              = 80
  type              = "HTTP"
  resource_path     = "/health-check"
  failure_threshold = "5"
  request_interval  = "30"

  tags {
    Name = "${var.route53_sub_domain}.${var.domain}-health-check"
  }
}

resource "aws_route53_record" "www_dns_primary" {
  zone_id         = "${var.route53_public_zone_id}"
  name            = "${var.route53_sub_domain}"
  type            = "A"
  health_check_id = "${aws_route53_health_check.domain_health_check.id}"
  set_identifier  = "${var.route53_sub_domain}-primary"

  alias {
    name                   = "${aws_elb.load_balancer.dns_name}"
    zone_id                = "${aws_elb.load_balancer.zone_id}"
    evaluate_target_health = false
  }

  failover_routing_policy {
    type = "PRIMARY"
  }
}

resource "aws_route53_record" "www_dns_failover" {
  zone_id        = "${var.route53_public_zone_id}"
  name           = "${var.route53_sub_domain}"
  type           = "A"
  set_identifier = "${var.route53_sub_domain}-failover"

  alias {
    name                   = "${aws_s3_bucket.elb_failover.website_domain}"
    zone_id                = "${aws_s3_bucket.elb_failover.hosted_zone_id}"
    evaluate_target_health = false
  }

  failover_routing_policy {
    type = "SECONDARY"
  }
}
