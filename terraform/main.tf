resource "aws_s3_bucket" "fraud_data" {
  bucket = "${var.account_id}-fraud-data-${var.region}"
  force_destroy = true

  tags = {
    Name = "fraud-data-bucket"
  }
}

resource "aws_sqs_queue" "fraud_alerts" {
  name = "fraud-alert-queue"
}

################################################
# IAM Roles for Lambdas
################################################
resource "aws_iam_role" "lambda_basic_role" {
  name = "fraud-lambda-basic-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_managed" {
  role       = aws_iam_role.lambda_basic_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "fraud-lambda-s3-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.fraud_data.arn,
          "${aws_s3_bucket.fraud_data.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_s3_policy" {
  name       = "attach-s3-policy"
  policy_arn = aws_iam_policy.s3_access_policy.arn
  roles      = [aws_iam_role.lambda_basic_role.name]
}

resource "aws_iam_policy" "sagemaker_invoke_policy" {
  name = "fraud-lambda-sagemaker-invoke"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sagemaker:InvokeEndpoint"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage"
        ],
        Resource = aws_sqs_queue.fraud_alerts.arn
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_sagemaker_policy" {
  name = "attach-sagemaker-policy"
  policy_arn = aws_iam_policy.sagemaker_invoke_policy.arn
  roles    = [aws_iam_role.lambda_basic_role.name]
}

################################################
# Lambda functions (using local zip files)
################################################

resource "aws_lambda_function" "preprocess" {
  filename         = "${path.module}/lambdas/zips/preprocess.zip"
  function_name    = "preprocess-function"
  handler          = "app.handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_basic_role.arn
  source_code_hash = filebase64sha256("${path.module}/lambdas/zips/preprocess.zip")

  environment {
    variables = {
      PROCESSED_PREFIX = "processed/"
    }
  }
}

resource "aws_lambda_function" "inference" {
  filename         = "${path.module}/lambdas/zips/inference.zip"
  function_name    = "inference-function"
  handler          = "app.handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_basic_role.arn
  source_code_hash = filebase64sha256("${path.module}/lambdas/zips/inference.zip")

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.fraud_alerts.id
      SAGEMAKER_ENDPOINT = var.sagemaker_endpoint_name
    }
  }
}

resource "aws_lambda_function" "retrain" {
  filename         = "${path.module}/lambdas/zips/retrain.zip"
  function_name    = "retrain-trigger"
  handler          = "app.handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_basic_role.arn
  source_code_hash = filebase64sha256("${path.module}/lambdas/zips/retrain.zip")

  environment {
    variables = {
      SAGEMAKER_ROLE_ARN = var.sagemaker_role_arn
      BUCKET = aws_s3_bucket.fraud_data.bucket
    }
  }
}

################################################
# S3 bucket notification to Lambda (preprocess)
################################################
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.fraud_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.preprocess.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_to_call_preprocess]
}

resource "aws_lambda_permission" "allow_s3_to_call_preprocess" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.preprocess.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.fraud_data.arn
}

################################################
# API Gateway REST API -> inference Lambda
################################################
resource "aws_api_gateway_rest_api" "api" {
  name = "fraud-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "predict" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "predict"
}

resource "aws_api_gateway_method" "post_predict" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.predict.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.predict.id
  http_method = aws_api_gateway_method.post_predict.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.inference.invoke_arn
}

resource "aws_lambda_permission" "apigw_allow" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.inference.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

################################################
# (Optional) SageMaker endpoint placeholder resource example
# Note: Creating a real SageMaker endpoint requires model artifacts and role; not fully automated here.
################################################
resource "aws_sagemaker_endpoint" "example" {
  count = var.sagemaker_endpoint_name == "" ? 0 : 0
  name  = "placeholder-endpoint"
}
