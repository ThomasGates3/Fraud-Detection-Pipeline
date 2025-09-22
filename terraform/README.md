# Fraud Detection Pipeline — Terraform version
This repo contains a Terraform translation of the SAM template you provided earlier.
It creates:
- S3 bucket for raw/processed data
- SQS queue for suspicious transactions
- 3 Lambda functions: preprocess, inference, retrain_trigger
- IAM roles and policies for Lambdas
- API Gateway REST API integrated with inference Lambda

IMPORTANT:
- Replace placeholder values (account IDs, ARNs, region) in `terraform.tfvars` or by passing variables.
- Terraform will reference local zip files for Lambda code found in `lambdas/zips/`.
- This package does **not** create a SageMaker training job or endpoint automatically — it includes variables and an example resource for a SageMaker endpoint placeholder. You must supply a valid `sagemaker_role_arn` and create or deploy a model separately or extend the resources as needed.
- To deploy:
  1. Install Terraform.
  2. Edit `terraform.tfvars` with your values.
  3. Run: `terraform init` then `terraform apply`.
