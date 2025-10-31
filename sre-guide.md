# SRE Guide for AWS Lambda & API Gateway System

## Overview
This document describes operational practices, monitoring, and reliability considerations for the AWS Lambda and API Gateway-based system.

---

## System Architecture
```
        +-------------+
        |  S3 Bucket  |
        +------+------+
               |
               v
        +-------------+
        |   SNS/SQS   |
        +------+------+
               |
               v
        +-------------------+
        |  AWS Lambda(s)    |
        +-------------------+
               |
               v
        +-------------------+
        |  API Gateway       |
        +-------------------+
               |
               v
        +-------------------+
        |  CloudWatch Logs  |
        +-------------------+
```

---

## Monitoring

### 1. Lambda Metrics (CloudWatch)
Monitor:
- `Errors` – function failures.
- `Duration` – execution latency.
- `Throttles` – concurrency limits.
- `Invocations` – total requests.

Set up CloudWatch alarms for key thresholds (e.g., >10% error rate).

### 2. API Gateway Metrics
- `5XXError` – server errors.  
- `4XXError` – client errors.  
- `Latency` – response time.  

### 3. Trigger Metrics
- **S3:** Number of events delivered.  
- **SNS/SQS:** Message delivery failures.  
- **EventBridge:** Rule invocation errors.

---

## Logging
- Use **CloudWatch Logs** for both Lambda and API Gateway.
- Ensure structured JSON logs for better searchability.
- Use centralized logging (e.g., AWS OpenSearch or Grafana Loki).

---

## Alerting
Integrate CloudWatch Alarms with:
- **PagerDuty**
- **Opsgenie**
- **Slack via SNS Topics**

---

## Reliability & Recovery
- **Lambda concurrency limits** should be configured.  
- Enable **DLQs (Dead Letter Queues)** for failed async Lambda invocations.  
- Use **API Gateway throttling** and **WAF** for DDoS protection.  

---

## Security
- Use least privilege IAM roles per function.  
- Rotate IAM access keys regularly.  
- Store secrets in **AWS Secrets Manager** or **SSM Parameter Store**.

---

## Cost Optimization
- Use AWS Cost Explorer to track Lambda and API Gateway usage.
- Configure provisioned concurrency only where necessary.
- Clean up unused triggers and stale versions.

---

## Performance Optimization
- Use Lambda layers for dependency reuse.  
- Minimize cold starts by using provisioned concurrency where required.  
- Enable compression in API Gateway responses.

---

## Incident Response
1. **Detect:** CloudWatch Alarm triggers.
2. **Notify:** PagerDuty/Slack alert.  
3. **Mitigate:** Rollback via Terraform or disable faulty trigger.
4. **Postmortem:** Review logs and metrics.

---
