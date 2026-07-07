output "repository_url" {
    description = "ECR Repository URL"
    value = aws_ecr_repository.app_repo.repository_url
}