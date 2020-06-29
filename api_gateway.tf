resource "aws_apigatewayv2_api" "main" {
  name          = local.lambda_function_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "main_lambda" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.main_lambda.id}"
}

resource "aws_apigatewayv2_integration" "main_lambda" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  payload_format_version = "1.0" # our PHP layer expects the 1.0 format
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.phpserver.invoke_arn
}

resource "aws_apigatewayv2_stage" "main_default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 100
  }

  lifecycle {
    ignore_changes = [
      deployment_id
    ]
  }
}

resource "aws_lambda_permission" "main_phpserver" {
  statement_id  = "AllowHTTPAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.phpserver.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.main.id}/*/$default"
}
