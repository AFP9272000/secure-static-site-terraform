resource "aws_kms_key" "site_key" {
  description             = "KMS key for encrypting S3 buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.common_tags
}