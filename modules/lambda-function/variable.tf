variable "function_name" {
  description = "Name of the Lambda function."
  type        = string
}

variable "handler" {
  description = "The function entrypoint in your code (e.g., index.handler)."
  type        = string
}

variable "runtime" {
  description = "Lambda runtime (e.g., nodejs20.x, python3.12)."
  type        = string
}

variable "package_filepath" {
  description = "Path to the Lambda deployment package (.zip)."
  type        = string
}

variable "additional_policy_arns" {
  description = "List of IAM policy ARNs to attach to the Lambda role (e.g., DynamoDB access)."
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda function."
  type        = map(string)
  default     = {}
}

variable "timeout" {
  description = "The amount of time (in seconds) that the function has to run before timing out."
  type        = number
  default     = 30
}


variable "sqs_trigger_arns" {
  description = "Map of SQS ARNs to create event source mappings for. Key is arbitrary ID."
  type        = map(string)
  default     = {}
}

variable "trigger_permissions" {
  description = "Map of permissions for general triggers (SNS, EventBridge/Scheduler, API Gateway). Key is statement ID."
  type        = map(object({
    principal  = string 
    source_arn = string
  }))
  default = {}
}

variable "s3_triggers" {
  description = "Map of S3 bucket event configurations to trigger the Lambda."
  type        = map(object({
    bucket_name = string
    events      = list(string)
    prefix      = optional(string)
    suffix      = optional(string)
  }))
  default = {}
}