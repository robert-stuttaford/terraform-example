#### private buckets

/*
    Datomic backups
*/

resource "aws_s3_bucket" "backups" {
  bucket        = "${var.system_name}-datomic-backups"
  force_destroy = true

  lifecycle {
    # prevent_destroy = true
  }
}

/*
    Zookeeper Exhibitor control state.
*/

resource "aws_s3_bucket" "exhibitor" {
  bucket        = "${var.system_name}-exhibitor"
  force_destroy = true

  lifecycle {
    # prevent_destroy = true
  }
}

#### public buckets

/*
    All client-side assets, from all apps.
    Each app's assets go into a subfolder.
*/

resource "aws_s3_bucket" "static_media" {
  bucket        = "${var.system_name}-static"
  acl           = "public-read"
  force_destroy = true

  lifecycle {
    # prevent_destroy = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://*.${var.domain}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Statement": [
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${var.system_name}-static/*"
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
      "Resource": "arn:aws:s3:::${var.system_name}-static"
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
      "Resource": "arn:aws:s3:::${var.system_name}-static/*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

/*
    All media uploaded via Builder.
*/

resource "aws_s3_bucket" "cog_media" {
  bucket        = "${var.system_name}-cog-media"
  acl           = "public-read"
  force_destroy = true

  lifecycle {
    # prevent_destroy = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://*.${var.domain}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Statement": [
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${var.system_name}-cog-media/*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

/*
    All videos we host for clients.
*/

resource "aws_s3_bucket" "video" {
  bucket        = "${var.system_name}-video"
  acl           = "public-read"
  force_destroy = true

  lifecycle {
    # prevent_destroy = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://*.${var.domain}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Statement": [
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${var.system_name}-video/*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

/*
    All media uploaded by users.
    Avatars, chat uploads, group logos.
*/

resource "aws_s3_bucket" "user_media" {
  bucket        = "${var.system_name}-user-media"
  acl           = "public-read"
  force_destroy = true

  lifecycle {
    # prevent_destroy = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://*.${var.domain}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Statement": [
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${var.system_name}-user-media/*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

/*
    All web media not present in static/resources.
    Downloads, blog media.
*/

resource "aws_s3_bucket" "web_media" {
  bucket        = "${var.system_name}-web-media"
  acl           = "public-read"
  force_destroy = true

  lifecycle {
    # prevent_destroy = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://*.${var.domain}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Statement": [
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${var.system_name}-web-media/*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

/*
    All media generated for users.
    Reports, certificates.
*/

resource "aws_s3_bucket" "generated_media" {
  bucket        = "${var.system_name}-generated-media"
  acl           = "public-read"
  force_destroy = true

  lifecycle {
    # prevent_destroy = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://*.${var.domain}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Statement": [
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${var.system_name}-generated-media/*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
}
