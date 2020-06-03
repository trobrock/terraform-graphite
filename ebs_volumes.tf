resource "aws_ebs_volume" "graphite_web_data" {
  availability_zone = var.availability_zone
  size              = var.grafana_web_data_volume_size

  tags = {
    Name     = "${var.name} graphite-web data"
    Graphite = "true"
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
  size              = var.grafana_data_volume_size

  tags = {
    Name     = "${var.name} grafana data"
    Graphite = "true"
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
  size              = var.carbon_data_volume_size

  tags = {
    Name     = "${var.name} carbon data"
    Graphite = "true"
  }
}

resource "aws_volume_attachment" "carbon_data" {
  device_name  = "/dev/${local.carbon_data_volume}"
  volume_id    = aws_ebs_volume.carbon_data.id
  instance_id  = aws_instance.graphite.id
  force_detach = true
}

# Automated snapshots
resource "aws_iam_role" "dlm_lifecycle_role" {
  count = var.enable_snapshots ? 1 : 0

  name = "graphite-dlm-lifecycle-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  count = var.enable_snapshots ? 1 : 0

  name = "graphite-dlm-lifecycle-policy"
  role = aws_iam_role.dlm_lifecycle_role[0].id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:DeleteSnapshot",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}

resource "aws_dlm_lifecycle_policy" "graphite_data" {
  count = var.enable_snapshots ? 1 : 0

  description        = "Graphite DLM lifecycle policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role[0].arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "2 weeks of daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 14
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = false
    }

    target_tags = {
      Graphite = "true"
    }
  }
}
