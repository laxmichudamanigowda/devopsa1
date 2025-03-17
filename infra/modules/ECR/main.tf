# ==========================================================================================
# If the ECR repository "my-demo-repo" already exists, run the following command to import it:
#terraform import aws_ecr_repository.app_repo my-demo-repo
# ==========================================================================================

# Try to fetch an existing ECR repository (for reference, but NOT for conditional creation)
data "aws_ecr_repository" "existing_repo" {
  name = "my-demo-repo"
}

# Create ECR repository (if not manually created)
resource "aws_ecr_repository" "app_repo" {
  name = "my-demo-repo"
  lifecycle {
    prevent_destroy = true
  }
}
