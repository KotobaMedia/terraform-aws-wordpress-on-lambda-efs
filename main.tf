provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

provider "random" {
  version = "~> 2.0"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs to assign to the Lambda function"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to assign to the Lambda function"
}

locals {
  security_group_ids   = concat(var.security_group_ids, [aws_security_group.efs_access.id])
  lambda_function_name = "wp-on-lambda-efs-${random_string.namespace.result}"
  assets_bucket_name   = "${local.lambda_function_name}-assets"
}

data "aws_subnet" "first" {
  id = var.subnet_ids[0]
}

data "aws_caller_identity" "current" {}
