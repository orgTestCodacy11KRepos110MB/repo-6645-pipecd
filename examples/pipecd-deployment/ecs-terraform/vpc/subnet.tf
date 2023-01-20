resource "aws_subnet" "public_a" {
  assign_ipv6_address_on_creation = false
  cidr_block                      = "10.0.0.0/20"
  map_public_ip_on_launch         = true
  vpc_id                          = aws_vpc.main.id
  availability_zone               = "ap-northeast-1a"

  tags = merge(var.tags, { "Name" = "public_a" })
}

resource "aws_subnet" "public_c" {
  assign_ipv6_address_on_creation = false
  cidr_block                      = "10.0.16.0/20"
  map_public_ip_on_launch         = true
  vpc_id                          = aws_vpc.main.id
  availability_zone               = "ap-northeast-1c"

  tags = merge(var.tags, { "Name" = "public_c" })
}

resource "aws_subnet" "public_d" {
  assign_ipv6_address_on_creation = false
  cidr_block                      = "10.0.32.0/20"
  map_public_ip_on_launch         = true
  vpc_id                          = aws_vpc.main.id
  availability_zone               = "ap-northeast-1d"

  tags = merge(var.tags, { "Name" = "public_d" })
}