variable "sg_type" {
  description = "The type of the security group ('public' or 'private')"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}
