provider "aws" {
  alias  = "target"
  region = var.aws_region

  assume_role {
    role_arn = var.target_provider_role_arn
  }
}

provider "aws" {
  alias  = "source"
  region = var.aws_region

  assume_role {
    role_arn = var.source_provider_role_arn
  }
}
