data "template_file" "grafana_datasources" {
  template = file("${path.module}/files/grafana_datasources.yaml")

  vars                = {
    region            = var.region
    enable_cloudwatch = var.enable_cloudwatch_role
    graphite_url      = "http://localhost"
  }
}

data "template_file" "setup_graphite" {
  template = file("${path.module}/files/setup-graphite.sh")

  vars = {
    apache_config_content               = file("${path.module}/files/graphite-web.conf")
    grafana_config_content              = file("${path.module}/files/grafana.ini")
    graphite_web_config_content         = file("${path.module}/files/graphite_local_settings.py")
    statsd_config_content               = file("${path.module}/files/statsd_config.js")
    collectd_config_content             = file("${path.module}/files/collectd_graphite.conf")
    carbon_storage_schemas_content      = file("${path.module}/files/carbon_storage_schemas.conf")
    carbon_storage_aggregations_content = file("${path.module}/files/carbon_storage_aggregations.conf")
    grafana_datasources_content         = data.template_file.grafana_datasources.rendered
    graphite_web_data_volume            = local.graphite_web_data_volume
    grafana_data_volume                 = local.grafana_data_volume
    carbon_data_volume                  = local.carbon_data_volume
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.setup_graphite.rendered
  }
}
