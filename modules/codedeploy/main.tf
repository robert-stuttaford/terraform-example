resource "aws_s3_bucket_object" "aws-code-deploy-sh" {
  bucket = "${aws_s3_bucket.ci.bucket}"
  key    = "aws-code-deploy.sh"
  source = "${path.module}/files/aws-code-deploy.sh"
  etag   = "${md5(file("${path.module}/files/aws-code-deploy.sh"))}"
}

resource "aws_s3_bucket_object" "checkout-branch-sh" {
  bucket = "${aws_s3_bucket.ci.bucket}"
  key    = "checkout-branch.sh"
  source = "${path.module}/files/checkout-branch.sh"
  etag   = "${md5(file("${path.module}/files/checkout-branch.sh"))}"
}

resource "aws_s3_bucket_object" "circle-changed-deps-py" {
  bucket = "${aws_s3_bucket.ci.bucket}"
  key    = "build-dependencies.py"
  source = "${path.module}/files/build-dependencies.py"
  etag   = "${md5(file("${path.module}/files/build-dependencies.py"))}"
}

resource "aws_s3_bucket_object" "s3sync-py" {
  bucket = "${aws_s3_bucket.ci.bucket}"
  key    = "s3sync.py"
  source = "${path.module}/files/s3sync.py"
  etag   = "${md5(file("${path.module}/files/s3sync.py"))}"
}

resource "aws_iam_user" "circleci" {
  name = "circleci"
}

resource "aws_iam_access_key" "circleci" {
  user = "${aws_iam_user.circleci.name}"
}

resource "aws_iam_user_policy" "circleci_policy" {
  name = "circleci_policy"
  user = "${aws_iam_user.circleci.name}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:ListObjects"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.ci.bucket}"
      ]
    },
    {
      "Action": [
        "s3:HeadObject",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.ci.bucket}*"
      ]
    },
    {
      "Action": [
        "s3:ListBucket",
        "s3:ListObjects"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.static_media_bucket}"
      ]
    },
    {
      "Action": [
        "s3:HeadObject",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.static_media_bucket}*"
      ]
    },
    {
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketVersions"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::cgn-terraform"
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObjectVersion"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::cgn-terraform*"
    },
    {
      "Action": [
        "codedeploy:CreateApplication",
        "codedeploy:GetApplication",
        "codedeploy:GetApplicationRevision",
        "codedeploy:RegisterApplicationRevision"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:codedeploy:*:${var.aws_account_id}:application:*"
      ]
    },
    {
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:CreateDeploymentGroup",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentGroup",
        "codedeploy:GetDeploymentInstance",
        "codedeploy:ListDeploymentInstances"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:codedeploy:*:${var.aws_account_id}:deploymentgroup:*"
      ]
    },
    {
      "Action": [
        "codedeploy:GetDeploymentConfig"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:codedeploy:*:${var.aws_account_id}:deploymentconfig:CodeDeployDefault.OneAtATime",
        "arn:aws:codedeploy:*:${var.aws_account_id}:deploymentconfig:CodeDeployDefault.HalfAtATime",
        "arn:aws:codedeploy:*:${var.aws_account_id}:deploymentconfig:CodeDeployDefault.AllAtOnce"
      ]
    }
  ],
  "Version": "2012-10-17"
}
EOF
}
