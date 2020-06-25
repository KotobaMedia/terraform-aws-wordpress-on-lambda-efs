resource "aws_s3_bucket" "assets" {
  bucket = local.assets_bucket_name
}
