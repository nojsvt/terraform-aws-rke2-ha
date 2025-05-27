provider "aws" {
  profile = ""
  region  = var.region
}

resource "aws_instance" "rke2_server1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "server1"
  }

  user_data = templatefile("${path.module}/user_data/server.tpl", {
    node_name      = "server1"
    token          = ""
    server1_ip     = ""
    is_server1     = true
    elastic_ip     = var.server1_public_ip
  })
}

resource "aws_eip_association" "server1_association" {
  instance_id   = aws_instance.rke2_server1.id
  allocation_id = var.server1_eip_allocation_id
}

output "server1_private_ip" {
  value = aws_instance.rke2_server1.private_ip
}
