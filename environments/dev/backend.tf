terraform {
  backend "s3" {
    bucket         = "my-tfstate-bucket-unique-name" 
    key            = "dev/api-gateway-lambda.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks" 
  }
}