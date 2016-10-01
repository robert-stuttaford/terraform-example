resource "aws_iam_role" "default" {
  name = "default_instance_profile"
  path = "/"

  assume_role_policy = <<EOF
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "autoscaling.amazonaws.com",
          "codedeploy.amazonaws.com"
        ]
      },
      "Sid": ""
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_instance_profile" "default_instance_profile" {
  name  = "default_instance_profile"
  roles = ["${aws_iam_role.default.name}"]
}

# this policy allows read access to the dynamo table
resource "aws_iam_role_policy" "peer_dynamo_access" {
  name = "peer_dynamo_access"
  role = "${aws_iam_role.default.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:BatchGetItem",
        "dynamodb:Scan",
        "dynamodb:Query"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:*:${var.aws_account_id}:table/${var.system_name}"
    }
  ]
}
EOF
}

# ONLY ENABLE THIS WHEN RESTORING DATOMIC DATABASE
resource "aws_iam_role_policy" "peer_dynamo_full_access" {
  name = "peer_dynamo_full_access"
  role = "${aws_iam_role.default.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": "dynamodb:*",
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:*:${var.aws_account_id}:table/${var.system_name}"
    }
  ]
}
EOF
}

# this policy allows peers to put to CloudWatch Logs
resource "aws_iam_role_policy" "peer_cloudwatch_logs" {
  name = "peer_cloudwatch_logs"
  role = "${aws_iam_role.default.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role_policy" "s3_all_access" {
  name = "s3_all_access"
  role = "${aws_iam_role.default.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codedeploy" {
  name = "codedeploy"
  role = "${aws_iam_role.default.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "autoscaling:CompleteLifecycleAction",
        "autoscaling:DeleteLifecycleHook",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeLifecycleHooks",
        "autoscaling:PutLifecycleHook",
        "autoscaling:RecordLifecycleActionHeartbeat",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeTags",
        "tag:GetTags",
        "tag:GetResources"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
}
