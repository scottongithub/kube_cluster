/*output "vpc_id" {
  description  = "VPC ID"
  value        = "${aws_vpc.k8s.id}"
}

output "subnet_id" {
  description = "Subnet ID"
  value       = "${aws_subnet.public-01.id}"
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = "${aws_instance.kub_master.id}"
}
*/

output "master_public_IP" {
  value       = "${aws_instance.kub_master.public_ip}"
}

output "worker_public_IP" {
  value       = "${aws_instance.kub_worker.*.public_ip}"
}

output "master_private_IP" {
  value       = "${aws_instance.kub_master.private_ip}"
}

output "worker_private_IP" {
  value       = "${aws_instance.kub_worker.*.private_ip}"
}

/*
output "load balancer DNS name" {
  value      = "${aws_lb.web.dns_name}"
}*/