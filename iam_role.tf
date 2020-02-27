data "aws_iam_policy_document" "grafana" {
  statement {
    sid = "AllowReadingMetricsFromCloudWatch"

    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowReadingTagsInstancesRegionsFromEC2"

    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
    ]

    resources = ["*"]
  }

  statement {
    sid       = "AllowReadingResourcesForTags"
    actions   = ["tag:GetResources"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "grafana" {
  count = var.enable_cloudwatch_role ? 1 : 0

  name               = "${var.name}-grafana"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "grafana" {
  count = var.enable_cloudwatch_role ? 1 : 0

  name   = "${var.name}-grafana-cloudwatch"
  role   = aws_iam_role.grafana[0].id
  policy = data.aws_iam_policy_document.grafana.json
}

resource "aws_iam_instance_profile" "grafana" {
  count = var.enable_cloudwatch_role ? 1 : 0

  name = "${var.name}-grafana"
  role = aws_iam_role.grafana[0].name
}
