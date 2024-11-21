# AWS Terraform EC2 VPC NAT Infrastructure with CI/CD Pipeline

This project uses Terraform to provision an AWS infrastructure that includes EC2 instances, a VPC, NAT gateways, and related resources. This CI/CD pipeline is configured using GitHub Actions to automate the deployment and destruction of infrastructure.

## Features

- Automatically creates and manages:
  - VPC with subnets and NAT gateway
  - EC2 instances (public and private)
  - S3 bucket for Terraform state
  - DynamoDB table for state locking
  - EC2 key pairs for secure SSH access
- Supports automated cleanup of all resources.
- Dynamic naming based on the GitHub `run_id` for each pipeline execution.

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
│   ├── backend.tf              # S3 and DynamoDB backend configuration
│   ├── terraform.tfvars        # Variables file for runtime configuration
│   └── modules/                # Reusable Terraform modules
└── README.md                   # Project documentation
```

---

## CI/CD Pipeline

The GitHub Actions pipeline automates the following tasks:

1. **Apply**:
   - Initializes Terraform and applies the configuration to deploy resources.
2. **Destroy**:
   - Destroys all Terraform-managed resources.
   - Deletes additional resources not managed by Terraform (e.g., S3 bucket, DynamoDB table, and key pairs).

### Commenting/Uncommenting Steps for Apply/Destroy

The pipeline is configured with steps for both `apply` and `destroy`. By default:
- `Apply` steps are enabled.
- `Destroy` steps are **commented out** to prevent accidental deletion of resources.

To **apply** the configuration:
1. Leave the `apply` steps uncommented.
2. Push your changes to trigger the pipeline.

To **destroy** the infrastructure:
1. Comment out the `apply` steps in `.github/workflows/terraform.yaml`.
2. Uncomment the `destroy` steps (Step 12–15) to clean up resources:
   ```yaml
   # Step 12: Terraform Destroy
   - name: Terraform Destroy
     run: terraform destroy --auto-approve

   # Step 13: Empty and Delete S3 Bucket
   - name: Empty and Delete S3 Bucket
     run: |
       RUN_ID=${{ github.run_id }}
       BUCKET_NAME="my-terraform-state-bucket-$RUN_ID"
       aws s3 rm s3://$BUCKET_NAME --recursive
       aws s3api delete-bucket --bucket $BUCKET_NAME --region us-west-2

   # Step 14: Delete DynamoDB Table
   - name: Delete DynamoDB Table
     run: |
       RUN_ID=${{ github.run_id }}
       TABLE_NAME="my-terraform-lock-table-$RUN_ID"
       aws dynamodb delete-table --table-name $TABLE_NAME --region us-west-2

   # Step 15: Delete EC2 Key Pairs
   - name: Delete EC2 Key Pairs
     run: |
       RUN_ID=${{ github.run_id }}
       aws ec2 delete-key-pair --key-name key-ec2-private-$RUN_ID
       aws ec2 delete-key-pair --key-name key-ec2-public-$RUN_ID
   ```

---

## How It Works

### Deployment

1. Navigate to the `src` directory:
   ```bash
   cd src
   ```
2. Update the `terraform.tfvars` file if necessary.
3. Commit and push changes to the repository.
4. The pipeline will:
   - Check if S3 bucket, DynamoDB table, and key pairs already exist.
   - Create or reuse resources dynamically based on the `run_id`.

### Cleanup

To destroy resources and clean up:
1. Uncomment the `destroy` steps in the pipeline.
2. Push the changes to trigger the destruction process.

---

## Important Notes

- **Dynamic Naming**: Resources are named using a unique identifier (`run_id`) to prevent conflicts.
- **State Management**: Terraform state is stored in an S3 bucket with locking enabled via DynamoDB.
- **Key Pairs**: The EC2 key pairs are securely generated and stored in the current working directory during the pipeline run.

---

## Troubleshooting

- **Duplicate Resources**: Ensure the `run_id` remains consistent across runs to avoid duplicates.
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