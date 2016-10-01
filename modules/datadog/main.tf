resource "aws_iam_policy" "dd_integration_policy" {
  name        = "DatadogAWSIntegrationPolicy"
  path        = "/"
  description = "DatadogAWSIntegrationPolicy"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "autoscaling:Describe*",
        "cloudtrail:DescribeTrails",
        "cloudtrail:GetTrailStatus",
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "ec2:Describe*",
        "ec2:Get*",
        "ecs:Describe*",
        "ecs:List*",
        "elasticache:Describe*",
        "elasticache:List*",
        "elasticloadbalancing:Describe*",
        "elasticmapreduce:List*",
        "iam:Get*",
        "iam:List*",
        "kinesis:Get*",
        "kinesis:List*",
        "kinesis:Describe*",
        "logs:Get*",
        "logs:Describe*",
        "logs:TestMetricFilter",
        "rds:Describe*",
        "rds:List*",
        "route53:List*",
        "ses:Get*",
        "ses:List*",
        "sns:List*",
        "sns:Publish",
        "sqs:GetQueueAttributes",
        "sqs:ListQueues",
        "sqs:ReceiveMessage"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role" "dd_integration_role" {
  name = "DatadogAWSIntegrationRole"

  assume_role_policy = <<EOF
{
  "Statement": {
    "Action": "sts:AssumeRole",
    "Condition": {
      "StringEquals": {
        "sts:ExternalId": "${var.shared_secret}"
      }
    },
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::464622532012:root"
    }
  },
  "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_policy_attachment" "allow_dd_role" {
  name       = "Allow Datadog PolicyAccess via Role"
  roles      = ["${aws_iam_role.dd_integration_role.name}"]
  policy_arn = "${aws_iam_policy.dd_integration_policy.arn}"
}
