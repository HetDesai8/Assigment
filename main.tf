data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = "${path.module}/lambda_package.zip"
}


module "lambda_function" {
  source = "./modules/lambda-function"

  function_name    = "${var.environment}-api-handler"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  package_filepath = data.archive_file.lambda_zip.output_path
  timeout          = 60

  environment_variables = {
    STAGE      = var.environment
    LOG_LEVEL  = "INFO"
  }

  s3_triggers = {
    on_put = {
      bucket_name = "lambda-trigger-${var.environment}-${var.aws_region}"
      events      = ["s3:ObjectCreated:*"]
    }
  }

  trigger_permissions = {
    allow_schedule = {
      principal  = "events.amazonaws.com"
      source_arn = "arn:aws:events:${var.aws_region}:123456789012:rule/lambda-hourly-${var.environment}"
    }
  }
}

module "api_gateway" {
  source = "./modules/api-gateway"

  api_name           = "${var.environment}-ServerlessAPI"
  resource_path      = var.api_resource_path
  http_method        = "POST"
  stage_name         = var.environment
  authorization_type = "NONE"

  lambda_invoke_arn = module.lambda_function.lambda_invoke_arn
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${module.api_gateway.api_id}/*/*/*"
}
