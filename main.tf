provider "cloudinit" {
  version = "2.0.0"
}

locals {
  graphite_web_data_volume = "xvdb"
  grafana_data_volume      = "xvdc"
  carbon_data_volume       = "xvdd"
}

data "aws_ami" "al2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "graphite" {
  ami                    = data.aws_ami.al2.id
  instance_type          = var.instance_type
  user_data_base64       = data.cloudinit_config.config.rendered
  key_name               = var.key_pair_name
  subnet_id              = var.subnets[0]
  vpc_security_group_ids = [aws_security_group.graphite.id]
  iam_instance_profile   = var.enable_cloudwatch_role ? aws_iam_instance_profile.grafana[0].name : null
  availability_zone      = var.availability_zone

  tags = {
    Name = var.name
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_eip" "graphite" {
  instance = aws_instance.graphite.id
  vpc      = true
}
