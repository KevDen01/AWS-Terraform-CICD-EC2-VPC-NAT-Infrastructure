provider "aws" {
  region = var.region
}

# Fetch the available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.vpc_cidr_block
}

# PUBLIC SUBNET
module "public_subnet" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = var.public_subnet_cidr
}

# PRIVATE SUBNET
module "private_subnet" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = var.private_subnet_cidr
}

# EC2 INSTANCE - PUBLIC SUBNET
module "ec2_public" {
  source            = "./modules/ec2"
  subnet_id         = module.public_subnet.subnet_id
  instance_type     = var.ec2_instance_type
  ami_id            = var.ec2_ami_id
  security_group_id = module.security_group_public.sg_id
  key_name          = "${var.key_name_prefix}public"
  instance_name     = var.instance_name["public"]
  associate_public_ip_address = true
}

# EC2 INSTANCE - PRIVATE SUBNET
module "ec2_private" {
  source            = "./modules/ec2"
  subnet_id         = module.private_subnet.subnet_id
  instance_type     = var.ec2_instance_type
  ami_id            = var.ec2_ami_id
  security_group_id = module.security_group_private.sg_id
  key_name          = "${var.key_name_prefix}private"
  instance_name     = var.instance_name["private"]
  associate_public_ip_address = false
}

# NAT GATEWAY
module "nat_gateway" {
  source           = "./modules/nat_gateway"
  public_subnet_id = module.public_subnet.subnet_id
}

# ROUTE TABLE -> IGW
resource "aws_route_table" "public_route_table" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.internet_gateway_id
  }
}

# ROUTE TABLE -> NAT GATEWAY
resource "aws_route_table" "private_route_table" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = module.nat_gateway.nat_gateway_id
  }
}

# ROUTE TABLE ASSOCIATIONS - PUBLIC + PRIVATE
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = module.public_subnet.subnet_id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = module.private_subnet.subnet_id
  route_table_id = aws_route_table.private_route_table.id
}

# SECURITY GROUPS - PUBLIC + PRIVATE
module "security_group_public" {
  source  = "./modules/security_group"
  sg_type = "public"
  vpc_id  = module.vpc.vpc_id
}

module "security_group_private" {
  source  = "./modules/security_group"
  sg_type = "private"
  vpc_id = module.vpc.vpc_id
}

