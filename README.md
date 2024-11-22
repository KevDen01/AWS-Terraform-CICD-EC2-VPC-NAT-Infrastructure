# AWS Terraform EC2 VPC NAT with CI/CD Pipeline

This project provisions an AWS infrastructure, including a VPC, EC2 instances, NAT gateways, and supporting resources, using Terraform. It integrates a CI/CD pipeline implemented with GitHub Actions for automated deployment, management, and cleanup of the infrastructure. The pipeline dynamically handles resource creation and reuses existing infrastructure.

---

## Features

- Automatically creates and manages:
  - VPC with subnets and NAT gateway
  - EC2 instances (public and private)
  - S3 bucket for Terraform state
  - DynamoDB table for state locking
  - EC2 key pairs for secure SSH access
- Checks if resources already exist to avoid duplication.
- Dynamically retrieves the S3 bucket name from AWS SSM Parameter Store for consistent state management.
- Supports automated cleanup of all resources.

---

## Getting Started

### Prerequisites

1. Install the following tools:
   - [Terraform CLI](https://www.terraform.io/downloads.html)
   - [AWS CLI](https://aws.amazon.com/cli/)
2. Configure your AWS credentials locally or in GitHub Actions:
   - **For Local Execution**:
     Set up AWS credentials using the AWS CLI:
     ```bash
     aws configure
     ```
   - **For GitHub Actions**:
     Add your AWS credentials as secrets in your GitHub repository:
     1. Go to your repository on GitHub.
     2. Navigate to **Settings > Secrets and variables > Actions > New repository secret**.
     3. Add the following secrets:
        - `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
        - `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
        - `AWS_SESSION_TOKEN`: Your temporary AWS session token.
        - `AWS_DEFAULT_REGION`: Your preferred AWS region (e.g., `us-west-2`).

---

## Project Structure

```plaintext
.
├── .github/
│   └── workflows/
│       └── terraform.yaml      # CI/CD pipeline for provisioning infrastructure
├── src/                        # Contains all Terraform configuration files
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output definitions
│   ├── backend.tf              # Dynamically updated backend configuration
│   └── modules/                # Reusable Terraform modules
└── README.md                   # Project documentation
```

---

## CI/CD Pipeline

The GitHub Actions pipeline automates the following tasks:

1. **Apply**:
   - Checks if the S3 bucket, DynamoDB table, and EC2 key pairs exist.
   - Creates the S3 bucket for Terraform state if it doesn’t exist and stores the name in AWS SSM Parameter Store.
   - Dynamically generates the `backend.tf` file to ensure consistent backend configuration.
   - Initializes Terraform and applies the configuration to deploy resources.
2. **Destroy**:
   - Cleans up resources by:
     - Destroying all Terraform-managed infrastructure.
     - Emptying and deleting the S3 bucket.
     - Deleting the DynamoDB table and EC2 key pairs.

---

### Commenting/Uncommenting Steps for Apply/Destroy

The pipeline is configured with steps for both `apply` and `destroy`. By default:
- **Apply** steps are enabled.
- **Destroy** steps are **commented out** to prevent accidental deletion of resources.

To **apply** the configuration:
1. Leave the `apply` steps uncommented.
2. Push your changes to trigger the pipeline.

To **destroy** the infrastructure:
1. Comment out the `apply` steps in `.github/workflows/terraform.yaml`.
2. Uncomment the `destroy` steps (Step 12–15) to clean up resources:
   ```yaml
   # Step 12: Terraform Destroy
   - name: Terraform Destroy
     working-directory: src
     run: terraform destroy --auto-approve

   # Step 13: Empty and Delete S3 Bucket
   - name: Empty and Delete S3 Bucket
     run: |
       BUCKET_NAME=$(aws ssm get-parameter --name /my-terraform/s3-bucket-name --query 'Parameter.Value' --output text)
       echo "Emptying S3 bucket: $BUCKET_NAME..."
       aws s3 rm s3://$BUCKET_NAME --recursive
       echo "Deleting S3 bucket: $BUCKET_NAME..."
       aws s3api delete-bucket --bucket $BUCKET_NAME --region us-west-2

   # Step 14: Delete DynamoDB Table
   - name: Delete DynamoDB Table
     run: |
       TABLE_NAME="my-terraform-lock-table"
       echo "Deleting DynamoDB table: $TABLE_NAME..."
       aws dynamodb delete-table --table-name $TABLE_NAME --region us-west-2

   # Step 15: Delete EC2 Key Pairs
   - name: Delete EC2 Key Pairs
     run: |
       PRIVATE_KEY_NAME="key-ec2-private"
       PUBLIC_KEY_NAME="key-ec2-public"
       echo "Deleting key pair: $PRIVATE_KEY_NAME..."
       aws ec2 delete-key-pair --key-name $PRIVATE_KEY_NAME
       echo "Deleting key pair: $PUBLIC_KEY_NAME..."
       aws ec2 delete-key-pair --key-name $PUBLIC_KEY_NAME
   ```

---

## How It Works

1. **First Run**:
   - Dynamically creates the S3 bucket with a unique name and stores it in AWS SSM Parameter Store.
   - Initializes Terraform and applies the configuration.
2. **Subsequent Runs**:
   - Retrieves the S3 bucket name from AWS SSM.
   - Reuses the existing bucket, DynamoDB table, and key pairs without duplication.

### Cleanup

To destroy resources and clean up:
1. Uncomment the `destroy` steps in the pipeline.
2. Push the changes to trigger the destruction process.

---

## Important Notes

- **State Management**: Terraform state is stored in a dynamically created S3 bucket with locking enabled via DynamoDB.
- **Resource Reuse**: The pipeline ensures existing resources are reused to avoid duplication.
- **Key Pairs**: EC2 key pairs are created only if they don’t already exist, simplifying management.

---

## Troubleshooting

- **Duplicate Resources**: Ensure the SSM parameter `/my-terraform/s3-bucket-name` exists and stores the correct bucket name.
- **Pipeline Errors**: Check GitHub Actions logs for detailed error messages.
- **Manual Cleanup**: If needed, manually delete the S3 bucket, DynamoDB table, and key pairs using the AWS CLI.

---

## Contributing

Feel free to fork this repository and make contributions. Please open an issue for bugs or feature requests.

---

## Author

This project was developed and is maintained by **Kevin Klein Kampmeier**.

You can reach me at [kevinklein@mac.com](mailto:kevinklein@mac.com).

Feel free to open issues or contribute to the project!