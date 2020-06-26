# WordPress on Lambda (EFS Version)

This is distributed as a Terraform module, unlike the last version which was a SAM template.

### AWS Resources included in this module.

* Lambda function
* EFS filesystem
* A security group allowing access from the Lambda function to the EFS filesystem
* API Gateway
* S3 bucket to store uploaded files
* CloudFront distribution to serve static assets directly (not yet)

### AWS Resources not included that are required to run this module.

* A VPC, with at least one private subnet that has Internet access (using either a NAT Gateway or NAT Instance)
* A database
* A security group that allows access to the database

### Required variables

* Additional Security group IDs to assign to the Lambda function
* Subnet IDs to assign to the Lambda function
