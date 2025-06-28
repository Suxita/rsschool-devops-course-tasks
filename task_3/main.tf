# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Create VPC
resource "aws_vpc" "k3s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "k3s-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "k3s_igw" {
  vpc_id = aws_vpc.k3s_vpc.id

  tags = {
    Name = "k3s-igw"
  }
}

# Create public subnet
resource "aws_subnet" "k3s_public_subnet" {
  vpc_id                  = aws_vpc.k3s_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "k3s-public-subnet"
  }
}

# Create private subnet
resource "aws_subnet" "k3s_private_subnet" {
  vpc_id            = aws_vpc.k3s_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "k3s-private-subnet"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "k3s_nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.k3s_igw]

  tags = {
    Name = "k3s-nat-eip"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "k3s_nat_gw" {
  allocation_id = aws_eip.k3s_nat_eip.id
  subnet_id     = aws_subnet.k3s_public_subnet.id

  tags = {
    Name = "k3s-nat-gw"
  }

  depends_on = [aws_internet_gateway.k3s_igw]
}

# Create route table for public subnet
resource "aws_route_table" "k3s_public_rt" {
  vpc_id = aws_vpc.k3s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k3s_igw.id
  }

  tags = {
    Name = "k3s-public-rt"
  }
}

# Create route table for private subnet
resource "aws_route_table" "k3s_private_rt" {
  vpc_id = aws_vpc.k3s_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.k3s_nat_gw.id
  }

  tags = {
    Name = "k3s-private-rt"
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "k3s_public_rta" {
  subnet_id      = aws_subnet.k3s_public_subnet.id
  route_table_id = aws_route_table.k3s_public_rt.id
}

# Associate private subnet with private route table
resource "aws_route_table_association" "k3s_private_rta" {
  subnet_id      = aws_subnet.k3s_private_subnet.id
  route_table_id = aws_route_table.k3s_private_rt.id
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.k3s_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# Security Group for K3s Cluster
resource "aws_security_group" "k3s_sg" {
  name        = "k3s-sg"
  description = "Security group for K3s cluster"
  vpc_id      = aws_vpc.k3s_vpc.id

  # SSH from bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # K3s API server from bastion
  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Allow all traffic within the security group
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-sg"
  }
}

# Create Key Pair
resource "aws_key_pair" "k3s_key" {
  key_name   = "k3s-key"
  public_key = file(var.public_key_path)

  tags = {
    Name = "k3s-key"
  }
}

# Random password for K3s token
resource "random_password" "k3s_token" {
  length  = 64
  special = false
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.k3s_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = aws_subnet.k3s_public_subnet.id

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y curl
              
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x kubectl
              sudo mv kubectl /usr/local/bin/
              
              sudo -u ubuntu mkdir -p /home/ubuntu/.kube
              sudo chown ubuntu:ubuntu /home/ubuntu/.kube
              EOF

  tags = {
    Name = "k3s-bastion"
  }
}

# K3s Master Node
resource "aws_instance" "k3s_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.k3s_key.key_name
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  subnet_id              = aws_subnet.k3s_private_subnet.id

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
                            
              curl -sfL https://get.k3s.io | \\
                K3S_TOKEN=${random_password.k3s_token.result} \\
                INSTALL_K3S_EXEC="--tls-san $PRIVATE_IP" \\
                sh -s - --write-kubeconfig-mode 644
              
              sleep 30
              
              systemctl enable k3s
              systemctl start k3s
              EOF
  )

  tags = {
    Name = "k3s-master"
  }
}

# K3s Worker Node
resource "aws_instance" "k3s_worker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.k3s_key.key_name
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  subnet_id              = aws_subnet.k3s_private_subnet.id
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              
              # Wait for master to be ready
              until nc -zv ${aws_instance.k3s_master.private_ip} 6443; do
                sleep 5
              done
              
              # Install k3s agent
              curl -sfL https://get.k3s.io | \\
                K3S_URL=https://${aws_instance.k3s_master.private_ip}:6443 \\
                K3S_TOKEN=${random_password.k3s_token.result} sh -
              
              # Ensure the service is running
              systemctl enable k3s-agent
              systemctl start k3s-agent
              EOF
  )

  depends_on = [aws_instance.k3s_master]

  tags = {
    Name = "k3s-worker"
  }
}