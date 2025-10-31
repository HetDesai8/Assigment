provider "aws" {
  region = var.aws_region
}


data "archive_file" "api_lambda_zip" {
  type        = "zip"
  source_dir  = "../../src/lambda-hello/" 
  output_path = "api_lambda_package.zip"
}


resource "aws_s3_bucket" "trigger_bucket" {
  bucket = "prod-lambda-trigger-bucket-${var.aws_region}" 
  force_destroy = false 
}

resource "aws_cloudwatch_event_rule" "hourly_schedule" {
  name                = "lambda-hourly-trigger-prod"
  description         = "Triggers Lambda every hour in production"
  schedule_expression = "rate(1 hour)"
}


module "api_lambda" {
  source = "../../modules/lambda-function"
  
  function_name    = "ProdAPIHandler" 
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  package_filepath = data.archive_file.api_lambda_zip.output_path
  timeout          = 60
  
  environment_variables = {
    STAGE = "prod" 
    LOG_LEVEL = "WARNING"
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
  
  api_name          = "ProdServerlessAPI" 
  resource_path     = "v1/users"
  http_method       = "POST"
  stage_name        = "prod" 
  authorization_type = "AWS_IAM" 
  
  lambda_invoke_arn = module.api_lambda.lambda_invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGatewayProd"
  action        = "lambda:InvokeFunction"
  function_name = module.api_lambda.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_id}/*/*" 
}