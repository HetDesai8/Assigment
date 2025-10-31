output "base_url" {
  description = "The base URL for the API Gateway stage."
  value       = aws_api_gateway_stage.stage.invoke_url
}

output "api_id" {
  description = "The ID of the REST API."
  value       = aws_api_gateway_rest_api.this.id
}