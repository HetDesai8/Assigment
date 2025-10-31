variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "lambda_source_dir" {
  description = "Directory of Lambda source code"
  type        = string
  default     = "./src/lambda-hello"
}

variable "api_resource_path" {
  description = "API Gateway resource path (single segment like 'users')"
  type        = string
  default     = "users"
}
