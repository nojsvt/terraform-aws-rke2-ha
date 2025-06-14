resource "aws_instance" "rke2_servers" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile = aws_iam_instance_profile.acl_server_instance_profile.name

  tags = {
    Name = "server${count.index + 2}"
    "kubernetes.io/cluster/mycluster" = "owned"
  }

  user_data = templatefile("${path.module}/user_data/server.tpl", {
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
  iam_instance_profile = aws_iam_instance_profile.acl_agent_instance_profile.name

  tags = {
    Name = "agent${count.index + 1}"
    "kubernetes.io/cluster/mycluster" = "owned"
  }

  user_data = templatefile("${path.module}/user_data/agent.tpl", {
    token      = var.rke2_token
    server1_ip = aws_instance.rke2_server1.private_ip
  })

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  depends_on = [aws_instance.rke2_server1]
}
