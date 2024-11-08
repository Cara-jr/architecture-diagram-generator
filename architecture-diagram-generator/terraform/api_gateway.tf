# API Gateway to trigger the Step Functions state machine
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "DiagramGeneratorAPI"
  description = "API Gateway to trigger the Diagram Generator Step Functions"
}

# API resource for the /generate endpoint
resource "aws_api_gateway_resource" "generate_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "generate"
}

# Method for the /generate endpoint
resource "aws_api_gateway_method" "generate_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.generate_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration with Step Functions
resource "aws_api_gateway_integration" "generate_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.generate_resource.id
  http_method             = aws_api_gateway_method.generate_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:states:action/StartExecution"

  request_templates = {
    "application/json" = <<EOF
{
    "input": "$util.escapeJavaScript($input.body)",
    "stateMachineArn": "${aws_sfn_state_machine.diagram_generator.arn}"
}
EOF
  }

  credentials = aws_iam_role.api_gateway_role.arn
}

# Method response
resource "aws_api_gateway_method_response" "generate_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.generate_resource.id
  http_method = aws_api_gateway_method.generate_method.http_method
  status_code = "200"
}

# Integration response
resource "aws_api_gateway_integration_response" "generate_integration_response" {
  rest_api_id         = aws_api_gateway_rest_api.api_gateway.id
  resource_id         = aws_api_gateway_resource.generate_resource.id
  http_method         = aws_api_gateway_method.generate_method.http_method
  status_code         = aws_api_gateway_method_response.generate_response.status_code
  response_templates  = {
    "application/json" = "$input.body"
  }
}

# Deploy API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.generate_integration]
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

# IAM Role for API Gateway to invoke Step Functions
resource "aws_iam_role" "api_gateway_role" {
  name = "APIGatewayInvokeStepFunctionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: {
          Service: "apigateway.amazonaws.com"
        },
        Action: "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "api_gateway_policy" {
  name        = "APIGatewayStepFunctionsPolicy"
  description = "Policy for API Gateway to invoke Step Functions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "states:StartExecution"
        ],
        Resource: aws_sfn_state_machine.diagram_generator.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_attach" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_gateway_policy.arn
}
