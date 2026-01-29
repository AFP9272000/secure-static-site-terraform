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

variable "price_class" {
  description = "CloudFront price class (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"
}

variable "geo_restriction_type" {
  description = "Geo restriction type: none, whitelist, or blacklist"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "List of ISO 3166-1-alpha-2 country codes for geo restriction"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Number of days to retain logs before expiration"
  type        = number
  default     = 365
}

variable "enable_geo_restriction" {
  description = "Enable geographic restrictions on CloudFront distribution"
  type        = bool
  default     = false
  }

variable "error_file" {
  description = "Local path to the error HTML file"
  type        = string
  default     = "error.html"
  }