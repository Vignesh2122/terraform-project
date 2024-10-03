provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "s3" {
  bucket = "terraform-experiments"
  acl    = "private"
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.s3.bucket
  key    = "document.txt"
  source = "/home/document.txt"
}
~  
