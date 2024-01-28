## Default HTTPS listener that blocks all traffic without valid custom origin header

resource "aws_alb_listener" "alb_default_listener_https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  #certificate_arn   = aws_acm_certificate.alb_certificate.arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }
  
  depends_on = [aws_acm_certificate.alb_certificate]
}

## Target Group for our service

resource "aws_alb_target_group" "service_target_group" {
  name                 = "${var.namespace}-TargetGroup-${var.environment}"
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = aws_vpc.ecr_vpc.id
  deregistration_delay = 120

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "60"
    matcher             = var.healthcheck_matcher
    path                = var.healthcheck_endpoint
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "30"
  }
  
  depends_on = [aws_alb.alb]
}