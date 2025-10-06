output "cloudfront_domain" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "bucket_name" {
  description = "The name of the S3 bucket storing the site contents"
  value       = aws_s3_bucket.site.bucket
}