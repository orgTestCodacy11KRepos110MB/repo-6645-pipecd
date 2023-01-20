
resource "aws_elasticache_subnet_group" "main" {
  description = "${var.project}-redis-sg"
  name        = "${var.project}-redis-sg"
  subnet_ids = [
    aws_subnet.public_a.id, aws_subnet.public_c.id, aws_subnet.public_d.id
  ]
}