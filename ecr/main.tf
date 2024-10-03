
resource "aws_ecrpublic_repository" "devops" {
  provider = aws.us-east-1
  repository_name = "ec2"

  catalog_data {
    about_text        = "About Text"
    architectures     = ["ARM"]
    description       = "Description"
    operating_systems = ["Linux"]
    usage_text        = "Usage Text"
  }

  tags = {
    env = "production"
  }
}