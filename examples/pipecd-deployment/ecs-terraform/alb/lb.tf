resource "aws_lb" "main" {
  name               = var.project
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_main.id]

  drop_invalid_header_fields = false

  access_logs {
    bucket  = var.access_log_bucket_name
    enabled = true
    prefix  = "alb-main"
  }

  subnets = var.subnet_ids

  idle_timeout               = "60"
  enable_deletion_protection = false
  enable_http2               = true

  # enable_waf_fail_open
  ip_address_type = "ipv4"


  tags = var.tags
}