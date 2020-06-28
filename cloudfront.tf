resource "aws_cloudfront_origin_access_identity" "assets" {
  comment = "(WordPress on Lambda) Identifies CloudFront to S3"
}

resource "aws_cloudfront_distribution" "main" {
  http_version    = "http2"
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"
  enabled         = true
  comment         = "WordPress on Lambda Main Distribution (${random_string.namespace.result})"

  # These are standard error code customizations to prevent CloudFront from
  # caching them for the default duration (300 seconds)
  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = 5
  }

  custom_error_response {
    error_code            = "500"
    error_caching_min_ttl = 1
  }

  custom_error_response {
    error_code            = "502"
    error_caching_min_ttl = 1
  }

  custom_error_response {
    error_code            = "503"
    error_caching_min_ttl = 1
  }

  custom_error_response {
    error_code            = "504"
    error_caching_min_ttl = 1
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    default_ttl = 0
    max_ttl     = 31536000
    min_ttl     = 0

    smooth_streaming = false

    target_origin_id = "WordPressBackend"

    forwarded_values {
      query_string = true

      cookies {
        forward = "whitelist"

        whitelisted_names = [
          "comment_author_*",
          "wordpress_*",
          "wp-*",
        ]
      }

      headers = [
        "Accept-Encoding",
      ]
    }
  }

  ordered_cache_behavior {
    path_pattern = "/wp-includes/*"

    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    default_ttl = 86400
    max_ttl     = 31536000
    min_ttl     = 0

    smooth_streaming = false
    target_origin_id = "WordPressBackend"

    forwarded_values {
      query_string            = true
      query_string_cache_keys = ["v", "ver"]

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern = "/wp-content/*"

    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    default_ttl = 86400
    max_ttl     = 31536000
    min_ttl     = 0

    smooth_streaming = false
    target_origin_id = "WordPressBackend"

    forwarded_values {
      query_string            = true
      query_string_cache_keys = ["v", "ver"]

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern = "/wp-login.php"

    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    default_ttl = 0
    max_ttl     = 31536000
    min_ttl     = 0

    smooth_streaming = false
    target_origin_id = "WordPressBackend"

    forwarded_values {
      query_string = true

      cookies {
        forward = "whitelist"

        whitelisted_names = [
          "comment_*",
          "wordpress_*",
          "wp-*",
        ]
      }

      headers = [
        "Accept-Encoding",
      ]
    }
  }

  ordered_cache_behavior {
    path_pattern = "/wp-admin/*"

    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    default_ttl = 0
    max_ttl     = 31536000
    min_ttl     = 0

    smooth_streaming = false
    target_origin_id = "WordPressBackend"

    forwarded_values {
      query_string = true

      cookies {
        forward = "whitelist"

        whitelisted_names = [
          "comment_author_*",
          "wordpress_*",
          "wp-*",
        ]
      }

      headers = [
        "User-Agent",
        "Accept-Encoding",
      ]
    }
  }

  origin {
    domain_name = trimprefix(aws_apigatewayv2_api.main.api_endpoint, "https://")
    origin_id   = "WordPressBackend"
    origin_path = ""

    custom_origin_config {
      http_port  = "80"
      https_port = "443"

      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_id   = "AssetsS3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.assets.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
    # ssl_support_method             = "sni-only"
  }
}
