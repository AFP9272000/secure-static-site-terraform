# Secure Static Site on AWS with Terraform

A production-ready Terraform configuration to host a secure, private-origin static website on AWS using S3, CloudFront, and WAF. The design follows security best practices by keeping the S3 site bucket private, using CloudFront Origin Access Control (OAC) to retrieve content, and protecting the distribution with AWS WAF. Optional logging, versioning and server-side encryption are enabled for observability and durability.

Key features
- Private S3 origin (objects not publicly accessible)
- CloudFront distribution with Origin Access Control (OAC) and HTTPS enforcement
- AWS WAF v2 Web ACL with managed rule sets and configurable rate limiting
- S3 server-side encryption (SSE-S3 / AES-256) and versioning
- Optional GitHub Actions workflow for CI/CD (format, validate, plan, apply)
- Modular Terraform code and example variables file

Architecture (conceptual)
```
  ┌─────────────┐   HTTPS    ┌──────────────┐
  │ End users   ├──────────▶│  CloudFront  │
  └─────────────┘           │ distribution │
                            │  + WAF rules │
                            └──────┬───────┘
                                   │
               Signed requests      │ (Origin Access Control)
                                   ▼
                         ┌─────────────────┐
                         │ S3 site bucket  │ (private origin)
                         └─────────────────┘
                                  ▲
         Access logs (optional)   │
                                  │
                         ┌──────────────────┐
                         │ S3 log bucket     │ (encrypted, versioned)
                         └──────────────────┘
```

Repository structure
- provider.tf — Terraform AWS provider configuration and required versions
- variables.tf — Variable declarations (region, bucket names, rate limit, tags, etc.)
- locals.tf — Shared locals (common tagging, naming helpers)
- kms.tf — Optional KMS resources (unused by default due to CloudFront/SSE‑KMS limitations)
- s3.tf — Site and log bucket definitions (versioning, encryption, policies)
- cloudfront.tf — CloudFront distribution, origin access control, viewer settings
- waf.tf — WAF Web ACL and rate limiting rules
- outputs.tf — Useful outputs (CloudFront domain, bucket ARNs)
- terraform.tfvars.example — Example variable values to copy into terraform.tfvars
- .github/workflows/terraform.yml — Optional GitHub Actions workflow for CI/CD
- index.html — Example landing page

Prerequisites
- AWS account with permissions to create S3, CloudFront, WAF, IAM/KMS (if used)
- Terraform >= 1.3 installed locally
- (If using GitHub Actions) repository secrets: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION
- (Optional) ACM certificate in us-east-1 for a custom domain on CloudFront

Quick start

1. Clone the repository
   git clone https://github.com/AFP9272000/secure-static-site-terraform.git
   cd secure-static-site-terraform

2. Configure variables
   Copy the example and edit values:
   cp terraform.tfvars.example terraform.tfvars

   Important variables to set:
   - region — AWS region (e.g. "us-east-1")
   - site_bucket_name — unique S3 bucket name for the website
   - log_bucket_name — unique S3 bucket name for access logs
   - rate_limit — allowed requests per 5 minutes per IP (WAF)
   - common_tags — tags applied to most resources

   Do not commit terraform.tfvars to version control.

3. Initialize and deploy
   terraform init
   terraform validate
   terraform plan -out=tfplan
   terraform apply tfplan

What this creates
- A private S3 bucket for website content (versioned, AES‑256 encrypted)
- A log S3 bucket for CloudFront access logs (versioned, AES‑256 encrypted)
- A CloudFront distribution with Origin Access Control (OAC)
- A WAF Web ACL with AWS-managed rules and a configurable rate-limit rule
- Optional GitHub Actions workflow (if enabled)

Uploading your website
Because the site bucket is private, upload objects using the AWS CLI (or SDK) with credentials that can write to the bucket used by Terraform:

aws s3 sync ./site s3://"your-site-buckets"/

If you make changes to objects, invalidate CloudFront or create an invalidation to refresh the cache.

Custom domain
To use a custom domain (e.g. www.example.com):
- Provision an ACM certificate in us-east-1 (required for CloudFront)
- Update cloudfront.tf with the ACM certificate ARN and aliases
- Create a DNS record (Route 53 A/ALIAS or CNAME) pointing to the CloudFront domain

Destroying the stack
To tear down resources:
terraform destroy

Note: force_destroy is enabled on the log bucket to allow terraform destroy to automatically empty it. Backup any site files you want to keep before destroying.

Logging & monitoring
- CloudFront access logs are written to the configured log bucket (AES‑256)
- Both buckets have versioning enabled for recovery from accidental overwrites
- Add CloudWatch alarms, SNS alerts, or other monitoring as needed for production

Notes & limitations
- Encryption: CloudFront cannot fetch objects encrypted with SSE-KMS in a straightforward anonymous way. For this reason the default uses SSE‑S3 (AES‑256). If your compliance requires KMS, consider using a custom origin that can decrypt or a different architecture.
- WAF rate limiting: Rate limits are defined per 5 minute window. Tune the rate_limit variable according to expected traffic patterns.
- Cost: Created resources incur AWS charges (S3 storage, CloudFront data transfer, WAF request fees, etc.). Monitor usage and tear down unused resources.
- State management: For teams, use a remote backend (S3 + DynamoDB locking). The example uses local state for simplicity.

Security considerations
- Keep terraform.tfvars and AWS credentials out of version control
- Use least privilege for the AWS principal used by CI/CD
- Regularly review WAF rules and CloudFront logging for suspicious activity
- Rotate keys and rotate IAM roles where possible

Contributing
Contributions welcome. Open an issue to discuss changes or submit a pull request.

License
This project is licensed under the MIT License — see the LICENSE file for details.

Further reading and references
- AWS CloudFront and S3 best practices
- AWS WAF managed rule groups
- Terraform docs: provider and state configurations
