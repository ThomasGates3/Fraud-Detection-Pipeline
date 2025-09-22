output "api_invoke_url" {
  description = "Invoke URL for the predict API (POST)"
  value       = "${aws_api_gateway_deployment.deployment.invoke_url}/predict"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.fraud_data.bucket
}

output "sqs_queue_url" {
  value = aws_sqs_queue.fraud_alerts.id
}
