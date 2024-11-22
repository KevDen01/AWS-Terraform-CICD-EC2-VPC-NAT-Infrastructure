output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.public_subnet.subnet_id
}

output "private_subnet_id" {
  value = module.private_subnet.subnet_id
}

output "ec2_public_instance_id" {
  value = module.ec2_public.instance_id
}

output "ec2_private_instance_id" {
  value = module.ec2_private.instance_id
}

output "public_sg_id" {
  value = module.security_group_public.sg_id
}

output "private_sg_id" {
  value = module.security_group_private.sg_id
}

output "ec2_public_instance_public_ip" {
  value = module.ec2_public.public_ip
}

output "ec2_private_instance_private_ip" {
  value = module.ec2_private.private_ip
}

output "s3_bucket_name" {
  value = var.s3_bucket_name
}