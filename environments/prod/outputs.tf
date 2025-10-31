output "api_base_url" {
  description = "The invocation URL for the Production API Gateway stage."
  value       = module.api_gateway.base_url 
}

output "api_gateway_id" {
  description = "The unique ID of the Production REST API Gateway."
  value       = module.api_gateway.api_id
}

output "lambda_function_name" {
  description = "The name of the Production Lambda function."
  value       = module.api_lambda.lambda_name
}

output "lambda_function_arn" {
  description = "The ARN of the Production Lambda function."
  value       = module.api_lambda.lambda_arn
}

output "s3_trigger_bucket_name" {
  description = "The name of the S3 bucket used as a trigger for the Production Lambda."
  value       = aws_s3_bucket.trigger_bucket.bucket
}

output "scheduler_rule_name" {
  description = "The name of the CloudWatch Event/Scheduler rule used in production."
  value       = aws_cloudwatch_event_rule.hourly_schedule.name
}