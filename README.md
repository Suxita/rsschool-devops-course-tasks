# AWS Infrastructure with Terraform

This project creates a complete AWS infrastructure setup including VPC, subnets, EC2 instances, NAT Gateway/Instance, and S3 bucket using Terraform.

## Architecture Overview

The infrastructure includes:
- **VPC** with public and private subnets across 2 availability zones
- **Bastion Host** in public subnet for secure access
- **Private EC2 instances** in each availability zone
- **NAT Gateway or NAT Instance** for outbound internet access from private subnets
- **S3 bucket** for application storage
- **Security Groups** with proper access controls

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- An existing AWS Key Pair (or create one named `rsschool-devops-key`)

## Quick Start

1. **Clone and navigate to the project directory**
   ```bash
   git clone https://github.com/Suxita/rsschool-devops-course-tasks
   cd rsschool-devops-course-tasks
   cd terraform	
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Review and customize variables** (optional)
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Plan the deployment**
   ```bash
   terraform plan
   ```

5. **Deploy the infrastructure**
   ```bash
   terraform apply
   ```

6. **Connect to instances**
   ```bash
   # Connect to bastion host
   ssh -i /path/to/your-key.pem ec2-user@<bastion-public-ip>
   
   # From bastion, connect to private instances
   ssh ec2-user@<private-instance-ip>
   ```

## NAT Configuration

By default, the infrastructure uses a **NAT Instance** (`enable_nat_gateway = false`) which is more cost-effective for development environments.

To use **NAT Gateway** instead (recommended for production):
```hcl
enable_nat_gateway = true
```

## Security Groups

- **Bastion SG**: SSH (22) from allowed CIDR blocks
- **Private SG**: SSH (22) from bastion, all traffic from VPC
- **NAT Instance SG**: HTTP/HTTPS from private subnets, SSH from bastion
- **Public SG**: SSH, HTTP, HTTPS from anywhere, all traffic from VPC

## Outputs

After deployment, Terraform provides:
- VPC and subnet IDs
- Instance IDs and IP addresses
- Security group IDs
- S3 bucket name and ARN
- NAT Gateway/Instance ID





## Cleanup

To destroy all resources:
```bash
terraform destroy
```
