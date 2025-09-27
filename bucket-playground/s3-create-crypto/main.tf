resource "aws_s3_bucket" "s3-lneu" {
  bucket = "lneu-poc-tf"        
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.s3.lneu.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}