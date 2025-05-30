resource "aws_instance" "rke2_servers" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "server${count.index + 2}"
  }

  user_data = templatefile("${path.module}/user_data/server.tpl", {
    node_name      = "server${count.index + 2}"
    token          = var.rke2_token
    server1_ip     = aws_instance.rke2_server1.private_ip
    is_server1     = false
    elastic_ip     = ""
  })

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  depends_on = [aws_instance.rke2_server1]
}

resource "aws_instance" "rke2_agents" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "agent${count.index + 1}"
  }

  user_data = templatefile("${path.module}/user_data/agent.tpl", {
    node_name  = "agent${count.index + 1}"
    token      = var.rke2_token
    server1_ip = aws_instance.rke2_server1.private_ip
  })

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  depends_on = [aws_instance.rke2_server1]
}
