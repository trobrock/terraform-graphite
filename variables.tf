variable "vpc_id" {
  description = "The VPC ID to launch this instance in"
  type        = string
}

variable "subnets" {
  description = "The subnets to launch the load balancer in"
  type        = list
}

variable "instance_type" {
  description = "The instance type to launch"
  type        = string
  default     = "t2.small"
}

variable "key_pair_name" {
  description = "The key pair name to enable ssh access"
  type        = string
  default     = null
}

variable "allow_ssh_from" {
  description = "CIDR blocks to allow ssh access to the instance"
  type        = list(string)
  default     = null
}

variable "availability_zone" {
  description = "The availability zone for the instance and EBS volumes"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM SSL Cert"
  type        = string
}

variable "domain" {
  description = "The full domain to launch the application on"
  type        = string
}

variable "zone_id" {
  description = "The Zone ID for the Route53 zone this is deploying in"
  type        = string
}

variable "enable_cloudwatch_role" {
  description = "Setup an IAM role to access cloudwatch from the instance"
  type        = bool
  default     = false
}

variable "name" {
  description = "The base name to use for resources created"
  type        = string
  default     = "graphite"
}

variable "region" {
  description = "The default region to use for cloudwatch in grafana"
  type        = string
  default     = "us-east-1"
}
