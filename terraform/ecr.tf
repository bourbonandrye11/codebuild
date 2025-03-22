terraform {
    backend "remote" {
        organization = "bourbonandrye11"
        workspaces {
            name = "actions"
        }
    }
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_ecrpublic_repository" "tf_ecr" {
    repository_name = "docker_test"
    tags = {
        Name = "docker_test"
    }
}

output "ecr_url" {
    value = aws_ecrpublic_repository.tf_ecr.repository_uri
}

output "ecr_name" {
    value = aws_ecrpublic_repository.tf_ecr.id
}