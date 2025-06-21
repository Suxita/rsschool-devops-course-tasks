resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
  public_key = file("~/.ssh/id_rsa.pub") 
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.bastion_instance_type
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = aws_subnet.public[0].id

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y htop
    echo "Bastion host configured successfully" > /var/log/bastion-setup.log
  EOF

  tags = {
    Name = "${var.project_name}-bastion"
    Type = "Bastion"
  }
}

resource "aws_instance" "nat" {
  count = var.enable_nat_gateway ? 0 : 1

  ami                     = data.aws_ami.nat_instance.id
  instance_type           = var.nat_instance_type
  key_name                = aws_key_pair.main.key_name
  vpc_security_group_ids  = [aws_security_group.nat_instance[0].id]
  subnet_id               = aws_subnet.public[0].id
  source_dest_check       = false

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT
    service iptables save
  EOF

  tags = {
    Name = "${var.project_name}-nat-instance"
    Type = "NAT"
  }
}