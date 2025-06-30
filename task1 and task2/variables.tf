variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "rsschool-devops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "nat_instance_type" {
  description = "Instance type for NAT instance"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "rsschool-devops-key"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway instead of NAT instance"
  type        = bool
  default     = false
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH to bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Legacy variables for compatibility
variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "rsschool-devops-course-tasks"
}

variable "github_org" {
  description = "GitHub username"
  type        = string
  default     = "Suxita"
}
