provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

provider "random" {
  version = "~> 2.0"
}

provider "archive" {
  version = "~> 1.0"
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

variable "domain_name" {
  type        = string
  description = "(optional) The domain name you would like to use for the CloudFront distribution. Note that you are responsible for setting the alias record or CNAME record."
  default     = null
}

variable "acm_certificate_arn" {
  type        = string
  description = "(optional) The ARN of the ACM Certificate you would like to attach to the CloudFront distribution. This needs to be in the us-east-1 (N. Virginia) region. Required if `domain_name` is set."
  default     = null
}

variable "cloudfront_minimum_protocol_version" {
  type        = string
  description = "(optional) The minimum protocol version CloudFront will negotiate with the client. Defaults to TLSv1.2_2018. Only works if `acm_certificate_arn` is provided."
  default     = "TLSv1.2_2018"
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.main.arn
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_hosted_zone_id" {
  value = aws_cloudfront_distribution.main.hosted_zone_id
}

output "efs_file_system_id" {
  value = aws_efs_file_system.main.id
}

output "efs_security_group_id" {
  value = aws_security_group.efs_access.id
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
