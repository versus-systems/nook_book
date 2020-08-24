output "libcluster-hosts" {
  value = <<HOSTS

hosts: [
  :"nook_book@${aws_instance.nookbook1.private_ip}",
  :"nook_book@${aws_instance.nookbook2.private_ip}"
]
HOSTS
}
