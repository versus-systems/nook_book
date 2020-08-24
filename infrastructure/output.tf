variable "sshkey" { default = "guide" }
variable "bastion_id" { default = "i-0f592d9fe5e38f33c" }

output "sshconfig" {
  value = <<SSHCONF

Host nookbook_bastion
  User ec2-user
  Hostname 18.188.0.20
  IdentityFile ~/.ssh/${var.sshkey}

Host nookbook1
  User ec2-user
  Hostname ${aws_instance.nookbook1.private_ip}
  ProxyCommand ssh -q -W %h:%p nookbook_bastion
  IdentityFile ~/.ssh/${var.sshkey}

Host nookbook2
  User ec2-user
  Hostname ${aws_instance.nookbook2.private_ip}
  ProxyCommand ssh -q -W %h:%p nookbook_bastion
  IdentityFile ~/.ssh/${var.sshkey}
SSHCONF
}

output "ssh-commands" {
  value = <<SSHCMDS

aws ec2-instance-connect send-ssh-public-key --instance-id ${var.bastion_id}  --instance-os-user ec2-user --ssh-public-key file://~/.ssh/${var.sshkey}.pub --availability-zone us-east-2a | cat
aws ec2-instance-connect send-ssh-public-key --instance-id ${aws_instance.nookbook1.id}  --instance-os-user ec2-user --ssh-public-key file://~/.ssh/${var.sshkey}.pub --availability-zone us-east-2c | cat
aws ec2-instance-connect send-ssh-public-key --instance-id ${aws_instance.nookbook2.id}  --instance-os-user ec2-user --ssh-public-key file://~/.ssh/${var.sshkey}.pub --availability-zone us-east-2c | cat
SSHCMDS
}

output "libcluster-hosts" {
  value = <<HOSTS

hosts: [
  :"nook_book@${aws_instance.nookbook1.private_ip}",
  :"nook_book@${aws_instance.nookbook2.private_ip}"
]
HOSTS
}
