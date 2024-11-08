variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to store generated files"
  default     = "hidden in public"
}

variable "claude_api_key" {
  description = "API Key for the Claude AI model"
}

variable "lambda_function_names" {
  type        = list(string)
  description = "List of Lambda function names"
  default     = ["translate_to_pseudocode", "generate_uml_code", "generate_diagram"]
}

variable "plantuml_layer_arn" {
  description = "hidden in public"
}
