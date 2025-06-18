# IAM Policy: acp-agent-policy
resource "aws_iam_policy" "acp_agent_policy" {
  name        = "acp-agent-policy"
  description = "IAM policy for acp-agent-role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM Role: acp-agent-role
resource "aws_iam_role" "acp_agent_role" {
  name               = "acp-agent-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "acp-agent-role"
  }
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "acp_agent_policy_attachment" {
  role       = aws_iam_role.acp_agent_role.name
  policy_arn = aws_iam_policy.acp_agent_policy.arn
}

# IAM Instance Profile: acp-agent-role-instance-profile
resource "aws_iam_instance_profile" "acp_agent_instance_profile" {
  name = aws_iam_role.acp_agent_role.name
  role = aws_iam_role.acp_agent_role.name
}
