variable "subnet_id" {
  description = "ID of the subnet"
}

variable "instance_type" {
  description = "EC2 instance type"
}

variable "ami_id" {
  description = "AMI ID"
}

variable "security_group_id" {
  description = "Security group ID"
  type = string
}

variable "key_name" {
  description = "EC2 Key Name"
  type = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "associate_public_ip_address" {
  description = "PublicIP for EC2 Instance true/false"
  type        = bool
}