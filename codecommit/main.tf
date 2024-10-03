provider "aws" {
  region = "ap-south-1"
}

resource "aws_codecommit_repository" "main" {
  repository_name = var.aws_codecommit_repository
  description = "new repo created"
}       
