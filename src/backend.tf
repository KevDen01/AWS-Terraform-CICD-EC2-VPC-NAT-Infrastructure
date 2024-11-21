# S3 Bucket and DynamoDB Table must be created manually first
# Alternatively use CLI

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket20011992"  # Name of your S3 bucket
    key            = "terraform/state.tfstate"    # Path where the state file will be stored in the S3 bucket
    region         = "us-west-2"                   # The region of your resources
    encrypt        = true                          # Enable encryption for the state file
    dynamodb_table = "terraform-state-lock"        # DynamoDB table for state locking
    acl            = "bucket-owner-full-control"  # ACL for the S3 bucket
  }
}