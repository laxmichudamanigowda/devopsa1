terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

# Data Source: Get latest ECR image for Lambda
data "aws_ecr_repository" "app_repo" {
  name = "my-demo-repo"
}

#data "aws_ecr_image" "latest_image" {
 # count           = length(data.aws_ecr_repository.app_repo.repository_url) > 0 ? 1 : 0
  #repository_name = "my-demo-repo"
 # most_recent     = true
#}


# Lambda Function with ECR Image
resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_function_name
  role          = var.lambda_role_arn 
  package_type  = "Image"
  image_uri = "010438510478.dkr.ecr.us-east-1.amazonaws.com/my-demo-repo:latest"
  

  environment {
    variables = {
      NODE_ENV = "dev"
    }
  }

# depends_on = [aws_iam_role_policy_attachment.lambda_exec_policy_attachment]
}

# API Gateway
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "lambda-container-api"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }
}

# Cognito User Pool
resource "aws_cognito_user_pool" "oidc" {
  name                   = "oidc-user-pool"
  username_attributes    = ["email"]
  auto_verified_attributes = ["email"]
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "oidc_client" {
  name         = "oidc-client"
  user_pool_id = aws_cognito_user_pool.oidc.id

  allowed_oauth_flows                 = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "email"]
  supported_identity_providers         = ["COGNITO"]

  callback_urls = ["http://localhost:3000/callback"]
  logout_urls   = ["https://localhost.com/logout"]

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]
}

# API Gateway Authorizer (JWT with Cognito)
resource "aws_apigatewayv2_authorizer" "oidc_auth" {
  api_id          = aws_apigatewayv2_api.lambda_api.id
  authorizer_type = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer   = "https://cognito-idp.us-east-1.amazonaws.com/${aws_cognito_user_pool.oidc.id}"
    audience = [aws_cognito_user_pool_client.oidc_client.id]
  }

  name = "oidc-authorizer"

  depends_on = [aws_cognito_user_pool.oidc, aws_cognito_user_pool_client.oidc_client]
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "prod"
  auto_deploy = true
}

# API Gateway Integration with Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.lambda_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.my_lambda.invoke_arn
}

# API Gateway Route
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id       = aws_apigatewayv2_api.lambda_api.id
  route_key    = "ANY /{proxy+}"
  target       = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorizer_id = aws_apigatewayv2_authorizer.oidc_auth.id
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_stage.lambda_stage.execution_arn}/*"
}
