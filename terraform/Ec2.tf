resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
public_key = var.ssh_public_key
  tags = {
    Name = "${var.project_name}-key"
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.bastion_instance_type
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

resource "aws_instance" "nat" {
  count = var.enable_nat_instance && !var.enable_nat_gateway ? 1 : 0

  ami                    = data.aws_ami.nat_instance.id
  instance_type          = var.nat_instance_type
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.nat_instance[0].id]
  subnet_id              = aws_subnet.public[0].id
  source_dest_check      = false

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -p
    /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    /sbin/iptables -F FORWARD
    service iptables save
  EOF



}