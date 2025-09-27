variable "aws_region" {
  description = "Region aWS"
  type        = string
  default     = "us-east-1"
}

variable "enable_readonly_account" {
  description = "Buckets S3 read access"
  type        = bool
  default     = true
}

variable "s3_write_buckets" {
  description = "Buckets S3 write access"
  type        = list(string)
  default     = [] 
}