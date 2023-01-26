resource "aws_instance" "fumidai" {
  ami                    = "ami-0b7546e839d7ace12"
  vpc_security_group_ids = [aws_security_group.fumidai.id]
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.key_pair.id
  instance_type          = "t2.micro"
  tags = {
    Name = "aws-fumidai-ec2"
  }
}