Architecture Overview
The infrastructure includes:

VPC: Virtual Private Cloud with DNS resolution enabled
Public Subnets: 2 public subnets in different Availability Zones
Private Subnets: 2 private subnets in different Availability Zones
Internet Gateway: Provides internet access to public subnets
Bastion Host: Secure access point to private subnet instances
Security Groups: Network-level security controls

Routing

Public Subnets: Route to Internet Gateway (0.0.0.0/0)
Private Subnets: Route to NAT Gateway/Instance (0.0.0.0/0)
Internal Communication: All subnets can communicate with each other

Prerequisites

AWS CLI configured with appropriate credentials
Terraform installed (version >= 1.0)
Key Pair created in AWS for EC2 instances

Security Groups
Bastion Host Security Group

Inbound: SSH (22) from anywhere
Outbound: All traffic

Private Instance Security Group

Inbound:

SSH (22) from Bastion Host
All traffic from VPC CIDR


Outbound: All traffic

NAT Instance Security Group (if enabled)

Inbound:

HTTP (80) from private subnets
HTTPS (443) from private subnets
SSH (22) from Bastion Host


Outbound: All traffic