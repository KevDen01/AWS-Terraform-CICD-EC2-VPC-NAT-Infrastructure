variable "region" {
  description = "The AWS region to deploy resources"
  default     = "us-west-2" # Select your Region
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  default     = "10.0.1.0/24"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ec2_ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-04dd23e62ed049936" # Replace with your region's AMI ID
}

variable "key_name_prefix" {
  description = "Key for EC2 Instances"
  type        = string
  default     = "key-ec2-"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform backend"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB Table for State Locking"
  type = string
}


variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = map(string)
  default = {
    "public"  = "public-ec2-instance"
    "private" = "private-ec2-instance"
  }
}

