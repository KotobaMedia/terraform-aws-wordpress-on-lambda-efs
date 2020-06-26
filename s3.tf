resource "aws_s3_bucket" "assets" {
  bucket = local.assets_bucket_name
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  ignore_public_acls = true
  restrict_public_buckets = true
}
