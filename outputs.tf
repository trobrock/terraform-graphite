output "hostname" {
  value = aws_eip.graphite.public_dns
}

output "iam_role_arn" {
  value = aws_iam_role.grafana[0].arn
}

output "ip" {
  value = aws_eip.graphite.public_ip
}
