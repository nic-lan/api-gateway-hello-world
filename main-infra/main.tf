provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "random_pet" "terraform_state_bucket_name" {
  prefix = "terraform-state"
  length = 4
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = random_pet.terraform_state_bucket_name.id

  # Commented out for simplicity
  #
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_s3_bucket_acl" "terraform_state_acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# The S3 should have versionining enabled.
# Commented out for simplicity
#
# resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
#   bucket = aws_s3_bucket.terraform_state.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_dynamodb_table" "dynamodb_terraform_state_lock" {
  name           = "my-lock-table"  # replace with your desired table name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Commented out for simplicity
  #
  # lifecycle {
  #   prevent_destroy = true
  # }
}
