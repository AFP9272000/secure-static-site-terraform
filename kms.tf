resource "aws_kms_key" "site_key" {
  description             = "KMS key for encrypting log bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true

policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Sid    = "EnableRootPermissions"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action   = "kms:*"
      Resource = "*"
    },
    {
      Sid    = "AllowKeyAdministration"
      Effect = "Allow"
      Principal = {
        AWS = data.aws_caller_identity.current.arn
      }
      Action   = "kms:*"
      Resource = "*"
    },
    {
      Sid    = "AllowCloudFrontLogging"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action = [
        "kms:Encrypt",
        "kms:GenerateDataKey*"
      ]
      Resource = "*"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }
  ]
})

  tags = local.common_tags
}

resource "aws_kms_alias" "site_key" {
  name          = "alias/${var.bucket_name}-key"
  target_key_id = aws_kms_key.site_key.key_id
}