variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 Size"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux
}

variable "capacity" {
  description = "instances 4 ASG"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "min instances 4 ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "max instances 4 ASG"
  type        = number
  default     = 3
}