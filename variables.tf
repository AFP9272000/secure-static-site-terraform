variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the main S3 bucket for website content"
  type        = string
}

variable "index_file" {
  description = "Local path to the index HTML file"
  type        = string
  default     = "index.html"
}

variable "log_bucket_name" {
  description = "Name of the S3 bucket used for access logs"
  type        = string
}

variable "rate_limit" {
  description = "Rate limit (requests per 5 minutes per IP) for WAF rate limiting rule"
  type        = number
  default     = 2000
}

variable "project_tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "secure-static-website"
    Environment = "prod"
  }
}