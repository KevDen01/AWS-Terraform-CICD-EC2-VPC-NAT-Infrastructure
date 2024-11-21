resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "myvpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}
