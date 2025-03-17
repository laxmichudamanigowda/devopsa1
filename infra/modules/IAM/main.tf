# Check if the IAM role already exists
data "aws_iam_role" "existing_lambda_exec_role" {
  name = "lambdaExecRoleHelloWorld1"
}

# Conditionally create the IAM role only if it doesn't exist
resource "aws_iam_role" "lambda_exec_role" {
  count = length(try(data.aws_iam_role.existing_lambda_exec_role.name, "")) > 0 ? 0 : 1
  name  = "lambdaExecRoleHelloWorld1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach AWSLambdaBasicExecutionRole policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attachment" {
  role       = coalesce(try(aws_iam_role.lambda_exec_role[0].name, ""), data.aws_iam_role.existing_lambda_exec_role.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create ECR pull policy (allows Lambda to pull images from ECR)
resource "aws_iam_policy" "ecr_pull_policy" {
  name        = "LambdaECRPullPolicy"
  description = "Allows Lambda to pull images from ECR"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      Resource = "*"
    },
    {
      Effect = "Allow",
      Action = "ecr:GetAuthorizationToken",
      Resource = "*"
    }]
  })
}

# Attach ECR pull policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_ecr_policy_attach" {
  role       = coalesce(try(aws_iam_role.lambda_exec_role[0].name, ""), data.aws_iam_role.existing_lambda_exec_role.name)
  policy_arn = aws_iam_policy.ecr_pull_policy.arn
}

# Output IAM Role ARN
output "lambda_role_arn" {
  value = coalesce(try(aws_iam_role.lambda_exec_role[0].arn, ""), data.aws_iam_role.existing_lambda_exec_role.arn)
}
