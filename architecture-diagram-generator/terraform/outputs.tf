output "api_gateway_url" {
  description = "API Gateway endpoint to trigger the Diagram Generator"
  value       = "${aws_api_gateway_deployment.api_deployment.invoke_url}${aws_api_gateway_stage.api_stage.stage_name}/generate"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.code_outputs_bucket.id
}
