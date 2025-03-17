variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM Role ARN for Lambda"
  type        = string
}

variable "image_name" {
  description = "ECR Image URI for Lambda"
  type        = string
}

variable "attach_basic_execution" {
  description = "Boolean to attach AWSLambdaBasicExecutionRole policy"
  type        = bool
  default     = true
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}
