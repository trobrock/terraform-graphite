output "hostname" {
  value = aws_eip.graphite.public_dns
}

output "iam_role_arn" {
  value = aws_iam_role.grafana[0].arn
}
