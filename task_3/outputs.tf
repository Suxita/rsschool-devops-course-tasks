output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_public_dns" {
  description = "Public DNS of the bastion host"
  value       = aws_instance.bastion.public_dns
}

output "k3s_master_private_ip" {
  description = "Private IP of the K3s master node"
  value       = aws_instance.k3s_master.private_ip
}

output "k3s_worker_private_ip" {
  description = "Private IP of the K3s worker node"
  value       = aws_instance.k3s_worker.private_ip
}

output "ssh_bastion_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.bastion.public_ip}"
}

output "ssh_master_via_bastion" {
  description = "SSH command to connect to master via bastion"
  value       = "ssh -i ${var.private_key_path} -o ProxyCommand='ssh -i ${var.private_key_path} -W %h:%p ubuntu@${aws_instance.bastion.public_ip}' ubuntu@${aws_instance.k3s_master.private_ip}"
}

output "kubectl_config_setup" {
  description = "Commands to set up kubectl on bastion"
  value       = <<EOT
1. SSH to bastion: ssh -i ${var.private_key_path} ubuntu@${aws_instance.bastion.public_ip}
2. SSH to master and get kubeconfig: ssh ubuntu@${aws_instance.k3s_master.private_ip} 'sudo cat /etc/rancher/k3s/k3s.yaml'
3. Copy the output to ~/.kube/config on bastion
4. Edit config: sed -i 's/127.0.0.1/${aws_instance.k3s_master.private_ip}/g' ~/.kube/config
5. Test: kubectl get nodes
EOT
}