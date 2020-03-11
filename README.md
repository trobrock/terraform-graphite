# Terraform Graphite

The purpose of this module is to make it very easy to setup a graphite+statsd+grafana server.

In the examples you will see call outs to other modules, below is the list of those and their source:

| Module Name | Project URL |
| ----------- | ----------- |
| vpc         | https://github.com/trobrock/terraform-vpc.git |
| acm_cert    | https://github.com/trobrock/terraform-acm-cert.git |

## Example

```terraform
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "internal" {
  name         = "my-domain.com"
  private_zone = false
}

module "graphite" {
  source = "git://github.com/trobrock/terraform-graphite.git?ref=v1.1.1"

  vpc_id                 = module.vpc.vpc_id
  subnets                = module.vpc.public_subnets
  key_pair_name          = "KEY_PAIR_NAME"
  availability_zone      = data.aws_availability_zones.available.names[0]
  acm_certificate_arn    = module.acm_cert_internal_wildcard.certificate_arn
  zone_id                = data.aws_route53_zone.internal.zone_id
  domain                 = "graphite"
  enable_cloudwatch_role = true
  # This enabled SSH from the world to this instance, it's useful for debugging and can be enabled
  # and disabled without rebuilding the instance. You SHOULD NOT leave this all the time.
  allow_ssh_from         = ["0.0.0.0/0"]
}
```
