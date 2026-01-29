output "cloudfront_domain" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution (for cache invalidation)"
  value       = aws_cloudfront_distribution.cdn.id
}

output "bucket_name" {
  description = "The name of the S3 bucket storing the site contents"
  value       = aws_s3_bucket.site.bucket
}

output "log_bucket_name" {
  description = "The name of the S3 bucket storing access logs"
  value       = aws_s3_bucket.log.bucket
}

output "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.cf.arn
}

output "website_url" {
  description = "The full HTTPS URL of the website"
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}