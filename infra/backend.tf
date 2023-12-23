
terraform {
  backend "s3" {
    bucket         = "bucket-name-placeholder"  # This will be overridden by -backend-config
    key            = "hello-world/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "my-lock-table"
    encrypt        = true
  }
}
