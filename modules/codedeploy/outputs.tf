output "ci_bucket" {
  value = "${aws_s3_bucket.ci.bucket}"
}

output "circleci_access_key" {
  value = "${aws_iam_access_key.circleci.id}"
}

output "circleci_access_secret" {
  value = "${aws_iam_access_key.circleci.secret}"
}

output "ansible_playbooks" {
  value = "s3://${aws_s3_bucket.ci.bucket}/ansible-playbooks.tar.gz"
}
