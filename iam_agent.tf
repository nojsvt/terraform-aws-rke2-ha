# IAM Policy: acl-agent-policy
resource "aws_iam_policy" "acl_agent_policy" {
  name        = "acl-agent-policy"
  description = "IAM policy for acl-agent-role"

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

# IAM Role: acl-agent-role
resource "aws_iam_role" "acl_agent_role" {
  name               = "acl-agent-role"
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
    Name = "acl-agent-role"
  }
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "acl_agent_policy_attachment" {
  role       = aws_iam_role.acl_agent_role.name
  policy_arn = aws_iam_policy.acl_agent_policy.arn
}
