resource "aws_s3_bucket" "ci" {
  bucket        = "${var.system_name}-ci"
  force_destroy = true

  lifecycle {
    # prevent_destroy = true
  }

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.master_aws_account_id}:root"
        ]
      },
      "Resource": "arn:aws:s3:::${var.system_name}-ci"
    },
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.master_aws_account_id}:root"
        ]
      },
      "Resource": "arn:aws:s3:::${var.system_name}-ci/*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
}
