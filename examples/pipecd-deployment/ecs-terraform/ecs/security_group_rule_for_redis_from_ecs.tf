resource "aws_security_group_rule" "redis_from_ecs" {
  security_group_id        = var.redis_security_group_id
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  description              = "Managed by Terraform"
}