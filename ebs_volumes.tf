resource "aws_ebs_volume" "graphite_web_data" {
  availability_zone = var.availability_zone
  size              = 1

  tags = {
    Name = "${var.name} graphite-web data"
  }
}

resource "aws_volume_attachment" "graphite_web_data" {
  device_name  = "/dev/${local.graphite_web_data_volume}"
  volume_id    = aws_ebs_volume.graphite_web_data.id
  instance_id  = aws_instance.graphite.id
  force_detach = true
}

resource "aws_ebs_volume" "grafana_data" {
  availability_zone = var.availability_zone
  size              = 1

  tags = {
    Name = "${var.name} grafana data"
  }
}

resource "aws_volume_attachment" "grafana_data" {
  device_name  = "/dev/${local.grafana_data_volume}"
  volume_id    = aws_ebs_volume.grafana_data.id
  instance_id  = aws_instance.graphite.id
  force_detach = true
}

resource "aws_ebs_volume" "carbon_data" {
  availability_zone = var.availability_zone
  size              = 5

  tags = {
    Name = "${var.name} carbon data"
  }
}

resource "aws_volume_attachment" "carbon_data" {
  device_name  = "/dev/${local.carbon_data_volume}"
  volume_id    = aws_ebs_volume.carbon_data.id
  instance_id  = aws_instance.graphite.id
  force_detach = true
}
