# Terraform Infrastructure with EC2 Instances, VPC, NAT Gateway, and Security Groups

This Terraform project provisions a cloud infrastructure on AWS, including:
- **Public and Private EC2 Instances** in **public** and **private subnets**
- **NAT Gateway** in the public subnet for private instance outbound internet access
- **Security Groups** for controlling traffic to the EC2 instances
- An optional **backend** configuration using **S3** and **DynamoDB** for state management and locking.

This README will guide you through setting up the environment, prerequisites, and how to use this Terraform configuration.

---

## Prerequisites

Before running this project, make sure you have the following set up:

### 1. **AWS Account**
You will need an active AWS account to deploy the resources.

### 2. **Terraform Installed**
Make sure that Terraform is installed on your local machine. You can check this by running:

```bash
terraform -version
```

If it's not installed, follow the instructions [here](https://www.terraform.io/downloads.html) to install Terraform.

### 3. **AWS CLI Configured**
You should have the AWS CLI installed and configured with your AWS credentials. To verify, run:

```bash
aws sts get-caller-identity
```

If this command returns your AWS account details, you're ready to proceed.

---

## Backend Setup

### **S3 and DynamoDB for Backend**

Before using the backend configuration, you must set up an **S3 bucket** and a **DynamoDB table** for state management.

#### **Create S3 Bucket**
Create an **S3 bucket** for storing the Terraform state file. You can do this using the AWS Console or AWS CLI. The bucket should be unique and in the same region where you plan to deploy the resources.

To create the bucket using AWS CLI:

```bash
aws s3api create-bucket --bucket my-terraform-state-bucket --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2
```

#### **Create DynamoDB Table**
Create a **DynamoDB table** for state locking. This table is used to prevent concurrent modifications of the Terraform state file.

To create the table using AWS CLI:

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-west-2
```

Make sure to replace `us-west-2` with the AWS region where you plan to deploy the resources.

---

### **Uncomment Backend Configuration**

Once the **S3 bucket** and **DynamoDB table** are created, uncomment the `backend.tf` section in your Terraform project to enable remote state management:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"  # Replace with your bucket name
    key            = "terraform/state.tfstate"
    region         = "us-west-2"  # Replace with your region
    encrypt        = true
    dynamodb_table = "terraform-state-lock"  # Replace with your DynamoDB table name
    acl            = "bucket-owner-full-control"
  }
}
```

Run the following command to initialize Terraform with the backend configuration:

```bash
terraform init
```

---

## Key Pair Requirements

### **Key Pairs in AWS Console**

For the EC2 instances to be accessible via SSH, you need to have **key pairs** created in your AWS account. The **key pairs must have the exact names** used in the `main.tf` file.

- **Public EC2 Instance**: The key pair name must be `key-ec2-public`.
- **Private EC2 Instance**: The key pair name must be `key-ec2-private`.

You can create key pairs in the **AWS Console** or **CLI**.

#### **Create Key Pairs Using AWS CLI**

To create a new key pair for the public EC2 instance:

```bash
aws ec2 create-key-pair --key-name key-ec2-public --query 'KeyMaterial' --output text > key-ec2-public.pem
chmod 400 key-ec2-public.pem
```

To create a new key pair for the private EC2 instance:

```bash
aws ec2 create-key-pair --key-name key-ec2-private --query 'KeyMaterial' --output text > key-ec2-private.pem
chmod 400 key-ec2-private.pem
```

Store the key files (`key-ec2-public.pem`, `key-ec2-private.pem`) safely, as you will need them to connect to the instances via SSH.

---

## How to Use

### 1. **Clone the Repository**

Clone this repository to your local machine:

```bash
git clone https://github.com/KevDen01/aws-terraform-ec2-vpc-nat-infrastructure
cd aws-terraform-ec2-vpc-nat-infrastructure
```

### 2. **Configure Terraform Variables**

Edit the `terraform.tfvars` file if needed to customize variables like `ami_id`, `instance_type`, etc. Ensure that the AWS region and other variables match your setup.

### 3. **Initialize Terraform**

Run the following command to initialize the Terraform working directory and download the necessary provider plugins:

```bash
terraform init
```

### 4. **Validate the Configuration**

You can run a validation to check your configuration for errors:

```bash
terraform validate
```

### 5. **Plan the Infrastructure**

Run the `terraform plan` command to see what Terraform will do before actually applying the changes:

```bash
terraform plan
```

### 6. **Apply the Infrastructure**

To apply the infrastructure and create the resources in AWS:

```bash
terraform apply
```

Terraform will prompt you to confirm the action. Type `yes` to proceed.

---

## NAT Gateway in the Public Subnet

This project also provisions a **NAT Gateway** in the **public subnet**. The NAT Gateway allows instances in the **private subnet** to access the internet for outgoing traffic, such as software updates, without exposing those instances to inbound internet traffic.

### **NAT Gateway Setup**:
- The **NAT Gateway** is placed in the **public subnet** and is associated with an **Elastic IP**.
- **Route tables** for the **private subnet** are updated to route internet-bound traffic through the **NAT Gateway**.

This setup ensures that the private EC2 instances can reach the internet for updates and other outbound traffic, while still being protected from inbound internet access.

---

## SSH Access to EC2 Instances

### **Connecting to the Public EC2 Instance via SSH**

To connect to the **public EC2 instance** using SSH, use the following command, replacing the `<public-ip>` with the actual public IP of the instance:

```bash
ssh -i key-ec2-public.pem ec2-user@<public-ip>
```

You can find the **public IP** of the EC2 instance in the **AWS Console** or retrieve it by running the following command to output it:

```bash
terraform output ec2_public_instance_public_ip
```

### **Connecting to the Private EC2 Instance**

The **private EC2 instance** will **not** have a public IP address, but you can connect to it via SSH using the **public EC2 instance** as a bastion host.

#### **Steps for SSH via Bastion Host:**

1. First, SSH into the **public EC2 instance** (which has a public IP).
2. From the public instance, SSH into the private instance using its private IP.

```bash
ssh -i key-ec2-public.pem ec2-user@<public-ip>  # SSH into the public EC2
```

Once connected to the public EC2 instance, SSH into the private instance (use the private IP):

```bash
ssh -i key-ec2-private.pem ec2-user@<private-ip>
```

You can find the **private IP** of the EC2 instance by running:

```bash
terraform output ec2_private_instance_private_ip
```

---

## Conclusion

This project provisions EC2 instances in both public and private subnets, with the corresponding security groups, routing, and a NAT Gateway. It leverages Terraform for infrastructure as code and can be easily extended with additional resources.

## Author

This project was developed and is maintained by **Kevin Klein Kampmeier**.

You can reach me at [kevinklein@mac.com](mailto:kevinklein@mac.com).

Feel free to open issues or contribute to the project!
