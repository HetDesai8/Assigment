variable "api_name" {
  description = "Name of the API Gateway REST API."
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway REST API."
  type        = string
  default     = "Serverless API deployed via Terraform."
}

variable "resource_path" {
  description = "The path part for the API Gateway resource (e.g., 'v1/items')."
  type        = string
}

variable "http_method" {
  description = "The HTTP method for the API Gateway (e.g., 'POST', 'GET', 'ANY')."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "The Invoke ARN of the Lambda function (output from lambda-function module)."
  type        = string
}

variable "stage_name" {
  description = "Name of the deployment stage (e.g., 'dev', 'prod')."
  type        = string
  default     = "dev"
}

variable "authorization_type" {
  description = "The authorization type for the method ('NONE', 'AWS_IAM', 'CUSTOM', 'COGNITO_USER_POOLS')."
  type        = string
  default     = "NONE"
}