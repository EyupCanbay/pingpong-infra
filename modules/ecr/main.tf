terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "< 6.0.0"
        }
    }
}

resource "aws_ecr_repository" "app_repo" {
    name = var.repository_name
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
}