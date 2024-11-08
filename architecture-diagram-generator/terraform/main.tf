# Create an S3 bucket to store generated files
resource "aws_s3_bucket" "code_outputs_bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"

  tags = {
    Name        = "CodeOutputsBucket"
    Environment = "Production"
  }
}

# Create Lambda functions
resource "aws_lambda_function" "translate_to_pseudocode" {
  function_name    = "translate_to_pseudocode"
  filename         = "${path.module}/../lambda_functions/translate_to_pseudocode/lambda_function.zip"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/../lambda_functions/translate_to_pseudocode/lambda_function.zip")
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.8"

  environment {
    variables = {
      ENV            = "prod"
      CLAUDE_API_KEY = var.claude_api_key
      S3_BUCKET_NAME = aws_s3_bucket.code_outputs_bucket.bucket
    }
  }
}

resource "aws_lambda_function" "generate_uml_code" {
  function_name    = "generate_uml_code"
  filename         = "${path.module}/../lambda_functions/generate_uml_code/lambda_function.zip"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/../lambda_functions/generate_uml_code/lambda_function.zip")
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.8"

  environment {
    variables = {
      ENV            = "prod"
      S3_BUCKET_NAME = aws_s3_bucket.code_outputs_bucket.bucket
    }
  }
}

resource "aws_lambda_function" "generate_diagram" {
  function_name    = "generate_diagram"
  filename         = "${path.module}/../lambda_functions/generate_diagram/lambda_function.zip"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/../lambda_functions/generate_diagram/lambda_function.zip")
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.8"

  layers = [var.plantuml_layer_arn]

  environment {
    variables = {
      ENV            = "prod"
      S3_BUCKET_NAME = aws_s3_bucket.code_outputs_bucket.bucket
    }
  }
}

# Create API Gateway REST API
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "CodeProcessorAPI"
  description = "API Gateway for the Architecture Diagram Generator"
}

# Create resources and methods for each Lambda function
locals {
  api_resources = [
    {
      name          = "translate"
      lambda        = aws_lambda_function.translate_to_pseudocode
      http_method   = "POST"
      path_part     = "translate"
    },
    {
      name          = "generate-uml"
      lambda        = aws_lambda_function.generate_uml_code
      http_method   = "POST"
      path_part     = "generate-uml"
    },
    {
      name          = "generate-diagram"
      lambda        = aws_lambda_function.generate_diagram
      http_method   = "POST"
      path_part     = "generate-diagram"
    }
  ]
}

# Loop over the resources to create API Gateway configurations
resource "aws_api_gateway_resource" "api_resources" {
  for_each    = { for resource in local.api_resources : resource.name => resource }
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = each.value.path_part
}

resource "aws_api_gateway_method" "api_methods" {
  for_each           = { for resource in local.api_resources : resource.name => resource }
  rest_api_id        = aws_api_gateway_rest_api.api_gateway.id
  resource_id        = aws_api_gateway_resource.api_resources[each.key].id
  http_method        = each.value.http_method
  authorization      = "NONE"
  api_key_required   = false
}

resource "aws_api_gateway_integration" "api_integrations" {
  for_each             = { for resource in local.api_resources : resource.name => resource }
  rest_api_id          = aws_api_gateway_rest_api.api_gateway.id
  resource_id          = aws_api_gateway_resource.api_resources[each.key].id
  http_method          = aws_api_gateway_method.api_methods[each.key].http_method
  integration_http_method = "POST"
  type                 = "AWS_PROXY"
  uri                  = each.value.lambda.invoke_arn
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "api_gateway_permissions" {
  for_each    = { for resource in local.api_resources : resource.name => resource }
  statement_id  = "AllowAPIGatewayInvoke_${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/${aws_api_gateway_method.api_methods[each.key].http_method}/${aws_api_gateway_resource.api_resources[each.key].path_part}"
}

# Deploy API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.api_integrations]
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  triggers = {
    redeployment = "${timestamp()}"
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "prod"
}
