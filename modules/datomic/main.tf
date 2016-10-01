# transactor role. ec2 instances can assume the role of a transactor
resource "aws_iam_role" "transactor" {
  name = "transactor"

  assume_role_policy = <<EOF
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Sid": ""
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

# policy with complete access to the dynamodb table
resource "aws_iam_role_policy" "transactor" {
  name = "dynamo_access"
  role = "${aws_iam_role.transactor.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:*:${var.aws_account_id}:table/${aws_dynamodb_table.datomic.name}"
    }
  ]
}
EOF
}

# policy with write access to cloudwatch
resource "aws_iam_role_policy" "transactor_cloudwatch" {
  name = "cloudwatch_access"
  role = "${aws_iam_role.transactor.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "cloudwatch:PutMetricData",
        "cloudwatch:PutMetricDataBatch"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "true"
        }
      },
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# s3 bucket for the transactor logs
resource "aws_s3_bucket" "transactor_logs" {
  bucket        = "${var.system_name}-datomic-logs"
  force_destroy = true

  lifecycle {
    # prevent_destroy = true
  }
}

# policy with write access to the transactor logs
resource "aws_iam_role_policy" "transactor_logs" {
  name = "s3_logs_access"
  role = "${aws_iam_role.transactor.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.transactor_logs.id}",
        "arn:aws:s3:::${aws_s3_bucket.transactor_logs.id}/*"
      ]
    }
  ]
}
EOF
}

# instance profile which assumes the transactor role
resource "aws_iam_instance_profile" "transactor" {
  name  = "datomic"
  roles = ["${aws_iam_role.transactor.name}"]
}

# transactor ami
data "aws_ami" "transactor" {
  most_recent = true
  owners      = ["754685078599"]

  filter {
    name   = "name"
    values = ["datomic-transactor-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["${var.transactor_instance_virtualization_type}"]
  }
}

# transactor launch config
resource "aws_launch_configuration" "transactor" {
  name_prefix                 = "datomic-"
  image_id                    = "${data.aws_ami.transactor.id}"
  instance_type               = "${var.transactor_instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.transactor.name}"
  security_groups             = ["${var.security_group_ids}"]
  user_data                   = "${data.template_file.transactor_user_data.rendered}"
  associate_public_ip_address = true

  ephemeral_block_device {
    device_name  = "/dev/sdb"
    virtual_name = "ephemeral0"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# user data template for bootstraping the transactor
data "template_file" "transactor_user_data" {
  template = "${file("${path.module}/files/bootstrap-transactor.sh")}"

  vars {
    xmx                    = "${var.transactor_xmx}"
    java_opts              = "${var.transactor_java_opts}"
    datomic_version        = "${var.datomic_version}"
    region                 = "${var.aws_region}"
    transactor_role        = "${aws_iam_role.transactor.name}"
    peer_role              = "${var.peer_role}"
    memory_index_max       = "${var.transactor_memory_index_max}"
    s3_log_bucket          = "${aws_s3_bucket.transactor_logs.id}"
    memory_index_threshold = "${var.transactor_memory_index_threshold}"
    cloudwatch_dimension   = "${var.cloudwatch_dimension}"
    object_cache_max       = "${var.transactor_object_cache_max}"
    license-key            = "${var.datomic_license}"
    dynamo_table           = "${aws_dynamodb_table.datomic.name}"
    cloudwatch_dimension   = "${var.cloudwatch_dimension}"
    memcached_uri          = "${var.memcached_uri}"
    datadog_api_key        = "${var.datadog_api_key}"
  }
}

# autoscaling group for launching transactors
resource "aws_autoscaling_group" "datomic_asg" {
  availability_zones   = "${var.availability_zones}"
  name                 = "datomic"
  max_size             = "${var.instance_count}"
  min_size             = "${var.instance_count}"
  launch_configuration = "${aws_launch_configuration.transactor.name}"
  vpc_zone_identifier  = ["${var.subnet_group_ids}"]

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Type"
    value               = "Datomic"
    propagate_at_launch = true
  }
}
