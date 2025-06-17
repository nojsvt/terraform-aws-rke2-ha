resource "aws_ec2_tag" "subnet_k8s_tag" {
  resource_id = var.subnet_id
  key         = "kubernetes.io/cluster/mycluster"
  value       = "owned"
}
