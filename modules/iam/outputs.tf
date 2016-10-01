output "instance_role_name" {
  value = "${aws_iam_role.default.name}"
}

output "instance_role_arn" {
  value = "${aws_iam_role.default.arn}"
}

output "instance_profile" {
  value = "${aws_iam_instance_profile.default_instance_profile.name}"
}
