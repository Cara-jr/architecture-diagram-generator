resource "aws_s3_bucket" "code_outputs_bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"

  tags = {
    Name        = "CodeOutputsBucket"
    Environment = "Production"
  }
}
