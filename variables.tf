variable "region" {
  default = "ap-southeast-1"
}

variable "key_name" {
  default = ""
}

variable "ami_id" {
  default = "ami-02c7683e4ca3ebf58"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "subnet_id" {
  default = ""
}

variable "security_group_id" {
  default = ""
}

variable "rke2_token" {
  default = ""
}

variable "server1_eip_allocation_id" {
  default = ""
}

variable "server1_public_ip" {
  default = ""
}

variable "server_iam_instance_profile" {
  default = "acl-server-role"
}

variable "agent_iam_instance_profile" {
  default = "acl-agent-role"
}
