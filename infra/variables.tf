variable "region" {
  description = "AWS region"
  type        = string
}

variable "repo_name" {
  description = "ECR repository name"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}
