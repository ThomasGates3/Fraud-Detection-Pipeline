variable "region" {
  type    = string
  default = "us-east-1"
}

variable "account_id" {
  type = string
  description = "AWS account id - used for naming. Replace with your account id."
}

variable "sagemaker_role_arn" {
  type = string
  description = "ARN of the SageMaker execution role (if you plan to create SageMaker resources)"
  default = ""
}

variable "sagemaker_endpoint_name" {
  type        = string
  description = "SageMaker endpoint name (if you already have one). Leave empty to use Lambda-based inference."
  default     = ""
}
