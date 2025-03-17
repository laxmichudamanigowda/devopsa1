terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.region
}

# Create ECR Repository
module "ECR" {
  source    = "./modules/ECR"
  repo_name = var.repo_name
}


# Lambda Function (including API Gateway & Cognito)
module "LAMDA" {
  source               = "./modules/LAMDA"
  ecr_repository_url = module.ECR.ecr_repository_url
  lambda_function_name =  var.lambda_function_name
  lambda_role_arn      = module.IAM.lambda_role_arn
  image_name           = "010438510478.dkr.ecr.us-east-1.amazonaws.com/my-demo-repo:latest"
  attach_basic_execution = true  # Ensure this argument is passed
}

# IAM Role for Lambda
module "IAM" {
  source = "./modules/IAM"
  lambda_role_arn = module.IAM.lambda_role_arn
}
