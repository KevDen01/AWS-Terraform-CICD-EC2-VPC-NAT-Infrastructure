locals { # List of Inbound Rules - HTTP/S, SSH
  ingress_rules = [
    {
      port        = 443
      description = "Port 443 - HTTPS"
    },
    {
      port        = 22
      description = "Port 22 - SSH"
    },
    {
      port        = 80
      description = "Port 80 - HTTP"
    }
  ]
}

resource "aws_security_group" "public" {
  count       = var.sg_type == "public" ? 1 : 0
  name        = "public_sg"
  description = "Allow inbound HTTP/S and SSH traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_rules

    content { # Iterates through all 3 values in locals.ingress_rules
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private" {
  count       = var.sg_type == "private" ? 1 : 0
  name        = "private_sg"
  description = "Allow outbound traffic for private subnet"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


