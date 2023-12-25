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

resource "aws_iam_role" "terraform_api_role" {
  name = "terraform_api_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "terraform_api_role_policy" {
  name = "s3_policy"
  role = aws_iam_role.terraform_api_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "s3:ListBucket"
        Resource = "${aws_s3_bucket.terraform_state.arn}"
      },
      {
        Effect = "Allow",
        Action = "s3:ListAllMyBuckets"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = ["s3:*"],
        Resource = "arn:aws:s3:::hello-world*"
      },
      {
        Effect = "Allow",
        Action = ["lambda:*"],
        Resource = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:HelloWorld"
      },
      {
        Effect = "Allow",
        Action = ["logs:*"],
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group*"
      },
      {
        Effect = "Allow",
        Action = "logs:CreateLogDelivery",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:*"
        ],
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/serverless_lambda*"
      },
      {
        Effect = "Allow",
        Action = ["apigateway:*"],
        Resource = "arn:aws:apigateway:${var.aws_region}::/apis*"
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = "${aws_s3_bucket.terraform_state.arn}/hello-world-api/terraform.tfstate"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource = "${aws_dynamodb_table.dynamodb_terraform_state_lock.arn}"
      }
    ]
  })
}

resource "aws_iam_user" "terraform_api_user" {
  name = "terraform_api_user"
  path = "/"
}

resource "aws_iam_policy" "terraform_api_policy" {
  name        = "terraform_api_policy"
  path        = "/"
  description = "Policy for Terraform API User"
  policy      = aws_iam_role_policy.terraform_api_role_policy.policy
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.terraform_api_user.name
  policy_arn = aws_iam_policy.terraform_api_policy.arn
}
