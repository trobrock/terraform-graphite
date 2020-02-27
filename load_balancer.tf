resource "aws_lb" "graphite" {
  name            = "graphite"
  subnets         = var.subnets
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "graphite" {
  name     = var.name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.graphite.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.graphite.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.graphite.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group_attachment" "graphite" {
  target_group_arn = aws_lb_target_group.graphite.arn
  target_id        = aws_instance.graphite.id
  port             = 80
}

resource "aws_route53_record" "graphite" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.graphite.dns_name
    zone_id                = aws_lb.graphite.zone_id
    evaluate_target_health = true
  }
}
