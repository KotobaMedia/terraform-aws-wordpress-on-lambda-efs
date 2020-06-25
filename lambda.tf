resource "aws_lambda_function" "phpserver" {
  filename      = "lambda_function_payload.zip"
  function_name = local.lambda_function_name
  role          = aws_iam_role.phpserver.arn
  handler       = "handler.php"
  memory_size   = 1024
  timeout       = 30

  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "provided"

  layers = [
    "arn:aws:lambda:us-west-2:777160072469:layer:php73:11"
  ]

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = local.security_group_ids
  }

  file_system_config {
    arn              = aws_efs_access_point.lambda.arn
    local_mount_path = "/mnt/root"
  }

  depends_on = [
    aws_efs_mount_target.main
  ]
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "phpserver" {
  name               = "wp-on-lambda-efs-${random_string.namespace.result}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "phpserver_eni_mgmt_access" {
  role       = aws_iam_role.phpserver.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}

data "aws_iam_policy_document" "phpserver_main" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.phpserver.name}",
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.phpserver.name}:log-stream:*"
    ]
  }
}

resource "aws_iam_role_policy" "phpserver_main" {
  name   = "WpOnLambdaMainRole"
  role   = aws_iam_role.phpserver.id
  policy = data.aws_iam_policy_document.phpserver_main.json
}

resource "aws_cloudwatch_log_group" "phpserver" {
  name = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 30
}
