resource "aws_s3_bucket" "assets" {
  bucket = local.assets_bucket_name
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "assets" {
  bucket = aws_s3_bucket.assets.id
  policy = data.aws_iam_policy_document.s3_assets_policy.json
}

data "aws_iam_policy_document" "s3_assets_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.assets.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.assets.iam_arn
      ]
    }
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.assets.arn
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.assets.iam_arn
      ]
    }
  }
}
