resource "aws_iam_role" "lambda_exec_role" {
  name               = "${var.function_name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy_basic" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "custom_policies" {
  for_each   = toset(var.additional_policy_arns)
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = each.value
}

resource "aws_lambda_function" "this" {
  filename         = var.package_filepath
  function_name    = var.function_name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  source_code_hash = filebase64sha256(var.package_filepath)
  
  environment {
    variables = var.environment_variables
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_triggers["bucket_arn"]
}

resource "aws_lambda_event_source_mapping" "sqs" {
  for_each          = var.sqs_trigger_arns
  event_source_arn  = each.value
  function_name     = aws_lambda_function.this.arn
  enabled           = true
  batch_size        = 10
}

resource "aws_lambda_permission" "triggers" {
  for_each      = var.trigger_permissions
  statement_id  = each.key
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = each.value.principal
  source_arn    = each.value.source_arn
}

resource "aws_s3_bucket_notification" "s3_triggers" {
  for_each = var.s3_triggers
  bucket   = each.value.bucket_name
  
  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = each.value.events
    filter_prefix       = lookup(each.value, "prefix", null)
    filter_suffix       = lookup(each.value, "suffix", null)
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  for_each      = var.s3_triggers
  statement_id  = "AllowExecutionFromS3-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${each.value.bucket_name}" 
}