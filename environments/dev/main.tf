provider "aws" {
  region = var.aws_region
}

data "archive_file" "api_lambda_zip" {
  type        = "zip"
  source_dir  = "../../src/lambda-hello/" 
  output_path = "api_lambda_package.zip"
}

resource "aws_s3_bucket" "trigger_bucket" {
  bucket = "dev-lambda-trigger-bucket-${var.aws_region}"
  force_destroy = true
}

resource "aws_cloudwatch_event_rule" "hourly_schedule" {
  name                = "lambda-hourly-trigger-dev"
  description         = "Triggers Lambda every hour"
  schedule_expression = "rate(1 hour)"
}

module "api_lambda" {
  source = "../../modules/lambda-function"
  
  function_name    = "DevAPIHandler"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  package_filepath = data.archive_file.api_lambda_zip.output_path
  timeout          = 60
  
  environment_variables = {
    STAGE = "dev"
    LOG_LEVEL = "INFO"
  }

  s3_triggers = {
    new_object_put = {
      bucket_name = aws_s3_bucket.trigger_bucket.id
      events      = ["s3:ObjectCreated:*"]
    }
  }

  trigger_permissions = {
    allow_scheduler_invoke = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.hourly_schedule.arn
    }
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.hourly_schedule.name
  arn  = module.api_lambda.lambda_arn
}


module "api_gateway" {
  source = "../../modules/api-gateway"
  
  api_name          = "DevServerlessAPI"
  resource_path     = "v1/users"
  http_method       = "POST"
  stage_name        = "dev"
  authorization_type = "NONE"
  lambda_invoke_arn = module.api_lambda.lambda_invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.api_lambda.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_id}/*/*" 
}