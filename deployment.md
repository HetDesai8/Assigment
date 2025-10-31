# Terraform Deployment Documentation

## Overview
This document explains how to deploy AWS Lambda and API Gateway infrastructure using Terraform. The project is modularized to support multiple Lambda functions with various triggers (S3, SNS, SQS, EventBridge, API Gateway).

---

## Directory Structure
```
assignment/
├── main.tf
├── providers.tf
├── variables.tf
├── modules/
│   ├── lambda-function/
│   └── api-gateway/
├── environments/
│   ├── dev/
│   └── prod/
├── src/
│   ├── lambda-hello/
│   └── lambda-processor/
└── buildspec.yml
```

---

## Prerequisites
- AWS CLI configured with appropriate credentials.
- Terraform v1.5+ installed.
- S3 bucket and DynamoDB table (optional) for remote state.
- IAM Role with permissions for Lambda, API Gateway, CloudWatch, and IAM.

---

## Deployment Steps

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Select Environment
```bash
cd environments/dev   # or prod
```

### 3. Plan the Deployment
```bash
terraform plan 
```

### 4. Apply the Deployment
```bash
terraform apply 
```

---

## CI/CD with AWS CodePipeline

### Step 1: Create a CodeCommit Repository
Push your Terraform code to an AWS CodeCommit repository.

### Step 2: Create a CodeBuild Project
Include a `buildspec.yml` file at the root:

```yaml
version: 0.2

phases:
  install:
    commands:
      - apt-get update -y
      - apt-get install -y unzip
      - curl -o terraform.zip https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
      - unzip terraform.zip && mv terraform /usr/local/bin/
  build:
    commands:
      - terraform init -backend-config="bucket=$STATE_BUCKET"
      - terraform plan -var-file="environments/$ENVIRONMENT/$ENVIRONMENT.tfvars" -out=tfplan
      - terraform apply -auto-approve tfplan
artifacts:
  files:
    - '**/*'
```

### Step 3: Create CodePipeline
Stages:
1. **Source:** CodeCommit repository.  
2. **Build:** CodeBuild project executes Terraform commands.  
3. **Deploy:** Terraform applies infrastructure changes.

---

## Deployment Considerations
- Separate state files per environment (dev/prod).  
- Use Terraform workspaces if you prefer a single state backend.  
- Review IAM roles and least privilege before deployment.  
- Use `terraform destroy` to clean up resources when no longer needed.

---
