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
  name                 = "${var.app_name}"
  availability_zones   = "${var.availability_zones}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  max_size             = "${var.max_size}"
  launch_configuration = "${aws_launch_configuration.launch_configuration.name}"
  vpc_zone_identifier  = ["${var.subnet_group_ids}"]

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
