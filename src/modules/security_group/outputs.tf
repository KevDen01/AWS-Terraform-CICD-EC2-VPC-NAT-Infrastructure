output "sg_id" {
  value = var.sg_type == "public" ? aws_security_group.public[0].id : aws_security_group.private[0].id
}