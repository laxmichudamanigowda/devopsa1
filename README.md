Step-by-Step CI/CD Pipeline Flow
Each step represents a block in the pipeline, with an arrow → indicating the flow.
1️ Developer Pushes Code to GitHub
 Developer → GitHub Repository (Code Storage)
•	The developer pushes application and Terraform code to the GitHub repository.
•	This triggers GitHub Actions workflows for infrastructure deployment and application deployment.
________________________________________
2️ GitHub Actions (Triggers CI/CD Workflows)
 GitHub Actions → Triggers Two Workflows:
    - Infrastructure Deployment (Terraform)
    - Application Deployment (Docker Build & Push)
•	infra.yml (Infrastructure Workflow)
o	Deploys AWS infrastructure using Terraform.
o	Authenticates with AWS using OIDC (IAM role assumed by GitHub Actions).
o	Terraform applies AWS resources:
GitHub Actions → Terraform → AWS Resources (ECR, Lambda, API Gateway, Cognito)
•	build.yml (Docker Build & Push Workflow)
o	Builds a Docker image from the application code.
o	Pushes the Docker image to Amazon ECR:
GitHub Actions → Docker Build → Push to AWS ECR
________________________________________
3️ AWS Elastic Container Registry (ECR) Stores Docker Images
    Docker Image → Amazon ECR
•	The built Docker image is stored in Amazon Elastic Container Registry (ECR).
•	This allows Lambda to pull the latest image when updating.
________________________________________
4️ Terraform Deploys AWS Resources
Terraform → AWS Infrastructure:
    - Creates IAM Roles
    - Provisions AWS Lambda
    - Sets up API Gateway
    - Configures Cognito Authentication
•	Terraform creates and configures AWS resources.
•	Key AWS resources created:
o	IAM Role for Lambda
o	Lambda function (container-based)
o	API Gateway
o	Cognito User Pool for Authentication
o	ECR for storing Docker images
________________________________________
5️ Lambda Function (Container-based) Pulls Image from ECR
   Lambda Function → Pulls Latest Image from ECR
•	The AWS Lambda function is updated with the latest Docker image from ECR.
•	The Lambda function runs in a containerized environment.
________________________________________
6️ API Gateway Exposes Lambda to Users
    API Gateway → Routes Requests to Lambda
•	API Gateway provides a public URL for clients to interact with the Lambda function.
•	The API is secured using Cognito authentication.
________________________________________
7️ Users Make API Requests
   User → API Gateway → Lambda Function → Response
•	Users call the API endpoint exposed by API Gateway.
•	API Gateway validates authentication (via Cognito, if enabled).
•	API Gateway forwards the request to Lambda.
•	Lambda processes the request and returns a response
