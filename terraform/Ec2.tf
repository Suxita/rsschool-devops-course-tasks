# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get NAT Instance AMI
data "aws_ami" "nat_instance" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# NAT Instance (only created when NAT Gateway is disabled)
resource "aws_instance" "nat" {
  count = var.enable_nat_gateway ? 0 : 1

  ami                    = data.aws_ami.nat_instance.id
  instance_type          = var.nat_instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.nat[0].id]
  subnet_id              = aws_subnet.public[0].id
  source_dest_check      = false

  tags = {
    Name        = "${var.project_name}-nat-instance"
    Environment = var.environment
    Type        = "NAT"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
              sysctl -p
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
              iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT
              service iptables save
              EOF
}

# Bastion Host in Public Subnet AZ1
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.bastion_instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = aws_subnet.public[0].id

  tags = {
    Name        = "${var.project_name}-bastion-host"
    Environment = var.environment
    Type        = "Bastion"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y htop net-tools
              echo "Bastion host configured successfully" > /var/log/bastion-setup.log
              EOF
}

# Private Instance in AZ1
resource "aws_instance" "private_az1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.private.id]
  subnet_id              = aws_subnet.private[0].id

  tags = {
    Name        = "${var.project_name}-private-vm-az1"
    Environment = var.environment
    Type        = "Private"
    AZ          = "AZ1"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y htop curl wget net-tools
              echo "Private instance in AZ1 configured successfully" > /var/log/private-setup.log
              EOF
}

# Private Instance in AZ2
resource "aws_instance" "private_az2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.private.id]
  subnet_id              = aws_subnet.private[1].id

  tags = {
    Name        = "${var.project_name}-private-vm-az2"
    Environment = var.environment
    Type        = "Private"
    AZ          = "AZ2"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y htop curl wget net-tools
              echo "Private instance in AZ2 configured successfully" > /var/log/private-setup.log
              EOF
}