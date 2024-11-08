# Lambda function: translate_to_pseudocode
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

# Lambda function: generate_uml_code
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

# Lambda function: generate_diagram
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
