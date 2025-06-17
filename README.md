# RKE2 High Availability Cluster on AWS with Terraform

<img width="230" alt="image" src="https://camo.githubusercontent.com/e0e6e05e3edcfa94bd0eb63a3c45a35110625bd53bef7ce2d314dcbc13837e5d/68747470733a2f2f646f63732e726b65322e696f2f696d672f6c6f676f2d686f72697a6f6e74616c2d726b65322e737667" />

This Terraform configuration deploys an RKE2 (Rancher Kubernetes Engine 2) high availability (HA) cluster on AWS.\
It consists of:

* 1 RKE2 server node (with Elastic IP)
* 2 additional RKE2 server nodes
* 3 RKE2 agent nodes

<img width="450" alt="image" src="https://docs.rke2.io/assets/images/rke2-production-setup-f5158274308e4a8976ea46273d6cb5c5.svg" />

Image source: [RKE2 High Availability Installation Guide](https://docs.rke2.io/install/ha)

## Prerequisites

* AWS account and credentials
* An IAM user or role with AdministratorAccess permissions
* A VPC with a working subnet and a security group allowing traffic between nodes
* An allocated Elastic IP for the first server node
* SSH key pair uploaded to AWS
* Terraform installed (`>= 0.13` recommended)

## File Overview

* `iam_server.tf`: Creates the IAM policy and role and instance profile for RKE2 servers
* `iam_agent.tf`: Creates the IAM policy and role and instance profile for RKE2 agents
* `ec2_server1.tf`: Provisions the first RKE2 server EC2 instance with its initial configuration
* `ec2_server_agent.tf`: Provisions additional RKE2 server and agent EC2 instances
* `user_data/server.tpl`: Template for installing and configuring RKE2 server nodes
* `user_data/agent.tpl`: Template for installing and configuring RKE2 agent nodes
* `subnet.tf`: Add a tag to your specified subnet: Key = `kubernetes.io/cluster/mycluster` Value = `owned`
* `variables.tf`: Variables for region, AMI, instance type, keys, etc

## Usage

### Step 1: Set Variables

Edit `variables.tf` and fill in all fields **except** `rke2_token`. \
Example values:

```hcl
variable "region" {
  default = "ap-southeast-1"
}

variable "key_name" {
  default = "your-key-name"
}

variable "ami_id" {
  default = "ami-02c7683e4ca3ebf58"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "subnet_id" {
  default = "subnet-xxxxxxxx"
}

variable "security_group_id" {
  default = "sg-xxxxxxxx"
}

variable "server1_eip_allocation_id" {
  default = "eipalloc-xxxxxxxx"
}

variable "server1_public_ip" {
  default = "xx.xx.xx.xx"
}
```

### Step 2: Initialize Terraform

```
terraform init
```

### Step 3: Create IAM Policies & Roles & Instance Profiles 

Create IAM Policies & Roles & Instance Profiles necessary for the Amazon Cloud Provider.
```
terraform apply \
  -target=aws_iam_policy.acl_server_policy \
  -target=aws_iam_role.acl_server_role \
  -target=aws_iam_policy.acl_agent_policy \
  -target=aws_iam_role.acl_agent_role \
  -target=aws_iam_instance_profile.acl_server_instance_profile \
  -target=aws_iam_instance_profile.acl_agent_instance_profile
```
Setting up the Amazon Cloud Provider Guide: \
  [https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-clusters-in-rancher-setup/set-up-cloud-providers/amazon](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-clusters-in-rancher-setup/set-up-cloud-providers/amazon)
  
### Step 4: Deploy First Server Node

```
terraform apply \
  -target=aws_instance.rke2_server1 \
  -target=aws_eip_association.server1_association
```
This will provision the first RKE2 server with an Elastic IP.

### Step 5: Retrieve the RKE2 Token

SSH into the first server node:
```
ssh -i your-key.pem ec2-user@<SERVER1_PUBLIC_IP>
```
Then, run:

```
sudo cat /var/lib/rancher/rke2/server/node-token
```
Copy the output and paste it into the `rke2_token` variable in variables.tf.

### Step 6: Deploy Remaining Nodes

```
terraform apply
```
This will provision the remaining 2 RKE2 servers and 3 agents.

### Step 7: Verify the Cluster

SSH into any one of the server nodes and run the following command to verify that all nodes have joined the cluster:
```
sudo /var/lib/rancher/rke2/bin/kubectl get nodes --kubeconfig /etc/rancher/rke2/rke2.yaml
```
You should see all 6 nodes (3 servers and 3 agents) listed with the status Ready.

### Step 8: Destroy All Resources

When you're done, destroy the infrastructure with:
```
terraform destroy
```
### Notes

- All nodes will be created in the same subnet and security group.
- The first server node must be up and running before the other nodes are created, as they require the `rke2_token` and server1_ip.

## References

- RKE2 Quickstart Guide (Agent/Worker Node Installation):  
  [https://docs.rke2.io/install/quickstart](https://docs.rke2.io/install/quickstart)

- RKE2 High Availability Installation Guide:  
  [https://docs.rke2.io/install/ha](https://docs.rke2.io/install/ha)

- Setting up the Amazon Cloud Provider Guide: \
  [https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-clusters-in-rancher-setup/set-up-cloud-providers/amazon](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-clusters-in-rancher-setup/set-up-cloud-providers/amazon)
