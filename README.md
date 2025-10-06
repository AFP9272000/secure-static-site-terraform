Secure Static Site on AWS with Terraform
Overview

This repository contains a complete Terraform configuration for hosting a static website securely on AWS. The design follows security best‑practices for a content delivery pipeline:

Amazon S3 acts as a private origin for the website files. Objects are not publicly accessible; the bucket policy only allows the CloudFront distribution to read them.

Amazon CloudFront serves the site to users. The distribution uses an Origin Access Control (OAC) to sign requests to S3 and enforces HTTPS for viewers. Optional logging writes access logs to a separate encrypted bucket.

AWS Web Application Firewall (WAF v2) protects the site from common web attacks. Managed rule sets cover common vulnerabilities (e.g. SQL injection, known bad IPs) and a rate‑limit rule throttles abusive clients.

Server‑side encryption (SSE‑S3) is enabled on both buckets. Although AWS Key Management Service (KMS) can encrypt objects, CloudFront cannot fetch anonymously encrypted objects. Amazon’s documentation notes that disabling ACLs or using SSE‑KMS on the log bucket prevents CloudFront from delivering logs
stackoverflow.com
 and that SSE‑KMS does not support anonymous requests
repost.aws
. Therefore the site and log buckets use the simpler AES‑256 (SSE‑S3) encryption.

Versioning and force‑destroy are enabled. Versioning protects against accidental overwrites. force_destroy on the log bucket ensures terraform destroy can clean up by automatically emptying the bucket.

Modular code improves readability and reuse. Resources are split across logical files (provider.tf, kms.tf, s3.tf, cloudfront.tf, waf.tf, outputs.tf) and controlled via variables.

An optional GitHub Actions workflow in .github/workflows/terraform.yml automatically formats, validates, plans and applies the Terraform on pushes to main.

Architecture diagram (conceptual)
┌─────────────┐   HTTPS    ┌──────────────┐
│ End users   ├──────────▶│ CloudFront   │
└─────────────┘           │ distribution │
                          │ + WAF rules  │
                          └──────┬───────┘
                                 │
                Signed requests  │ (Origin Access Control)
                                 ▼
                       ┌─────────────────┐
                       │ S3 site bucket │  (private origin)
                       └─────────────────┘
                                ▲
         Access logs (optional) │
                                │
                       ┌──────────────────┐
                       │ S3 log bucket    │  (encrypted, versioned)
                       └──────────────────┘

Repository structure
File / folder	Purpose
provider.tf	Defines the Terraform AWS provider and required versions.
variables.tf	Declares variables such as AWS region, bucket names, rate limit and tagging.
locals.tf	Consolidates common tags applied to all resources.
kms.tf	(Optional) Contains KMS resources if you wish to use customer‑managed keys. Currently unused because CloudFront cannot serve SSE‑KMS encrypted objects
repost.aws
.
s3.tf	Creates the site bucket and log bucket, enabling versioning, encryption (AES‑256), logging, bucket policies and force‑destroy.
cloudfront.tf	Configures the CloudFront distribution, origin access control (OAC) and HTTPS viewer settings. Logging to the log bucket is enabled.
waf.tf	Defines the WAF Web ACL with AWS‑managed rules and a configurable rate limit.
outputs.tf	Exposes the CloudFront domain name and bucket ARN after deployment.
.github/workflows/terraform.yml	GitHub Actions workflow to check formatting and deploy automatically.
terraform.tfvars.example	Sample variable values for users to copy into their own terraform.tfvars.
index.html	Example landing page to upload to the site bucket.
Prerequisites

AWS account with permissions to create S3 buckets, CloudFront distributions, WAFs and KMS keys.

Terraform >= 1.3 installed locally. See Terraform installation instructions
.

GitHub repository configured with repository secrets
 if you use the provided workflow: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_REGION.

SSL certificate (optional): If you want to use a custom domain, provision an ACM certificate in the desired AWS region and update the CloudFront distribution accordingly.

Usage
1. Clone this repository
git clone https://github.com/AFP9272000/secure-static-site-terraform.git
cd secure-static-site-terraform

2. Configure your variables

Copy the example variables file and edit it with your desired values:

cp terraform.tfvars.example terraform.tfvars

# open terraform.tfvars in your editor and set:
# - region             (e.g. "us-east-2")
# - site_bucket_name   (unique name for the website bucket)
# - log_bucket_name    (unique name for the log bucket)
# - rate_limit         (e.g. 2000 requests per 5 minutes)
# - common_tags        (project tags like Project="StaticSite", Environment="dev")
# - alert_email        (for CPU alarms if using EC2; optional)


Do not commit terraform.tfvars to version control, as it may contain sensitive values.

3. Initialise and deploy

Run the following commands in the root of the repository:

terraform init          # install providers and modules
terraform validate      # confirm the configuration is syntactically valid
terraform plan -out=tfplan  # preview the changes
terraform apply tfplan  # apply the infrastructure


Terraform will create:

A private S3 bucket for your static website, with versioning and AES‑256 encryption.

A second S3 bucket for access logs, also versioned and encrypted.

A CloudFront distribution with an Origin Access Control (OAC) that restricts origin access to CloudFront.

A WAF Web ACL with AWS‑managed rule sets and a configurable rate‑limit.

An optional GitHub Actions pipeline that runs the above commands automatically.

After deployment, Terraform will output the CloudFront domain name (e.g. d123abcde.cloudfront.net). Upload your website files (e.g. index.html, CSS, images) to the site bucket under the ./terraform directory:

aws s3 sync ./terraform s3://<your-site-bucket>/


Note: because the bucket is private and encrypted, you must upload via the AWS CLI or SDK using the same credentials used for deployment.

4. (Optional) Custom domain

To use your own domain (e.g. www.example.com), you will need:

A valid ACM certificate in us‑east‑1 if using a CloudFront distribution. Update the cloudfront.tf file with the certificate ARN and domain aliases.

A DNS record (e.g. Route 53 A or CNAME) pointing to the CloudFront domain.

5. Destroying the stack

To tear down all resources, run:

terraform destroy


Because force_destroy is set on the log bucket, Terraform will automatically empty and delete it. The site bucket is also deleted; be sure to back up any website files you wish to keep.

Logging and monitoring

By default, CloudFront access logs are stored in the log bucket with AES‑256 encryption. We enable ACLs on the log bucket and object ownership of ObjectWriter so CloudFront can write logs. AWS warns that disabling ACLs prevents CloudFront from writing logs
stackoverflow.com
. Versioning on both buckets allows recovery of overwritten objects. You can add additional monitoring by creating CloudWatch alarms or integrating with AWS Budgets.

Notes and limitations

Encryption: CloudFront cannot fetch objects encrypted with SSE‑KMS or bucket keys. As a result, this configuration uses SSE‑S3 (AES‑256) for both buckets
repost.aws
. If your compliance policies require KMS, you will need to use a different origin (e.g. an API Gateway or a custom origin) or implement a Lambda@Edge function to decrypt objects.

Rate limiting: The WAF rate limit variable controls how many requests per five minutes are allowed from a single IP. Adjust this value based on expected traffic.

Cost considerations: The resources created here incur AWS charges—S3 storage, CloudFront data transfer, and WAF request fees. Monitor your usage and tear down the stack when not needed.

State management: For collaborative environments, configure a remote state backend (e.g. an S3 bucket with DynamoDB locking) in provider.tf. The sample uses local state for simplicity.

Contributing

Contributions and improvements are welcome! Feel free to open an issue or submit a pull request.

License

This project is licensed under the MIT License. See the LICENSE
file for details.
