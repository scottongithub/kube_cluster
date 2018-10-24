resource "aws_security_group" "k8s" {
  name        = "k8s"
  vpc_id      = "${aws_vpc.k8s.id}"
  tags {
    Name        = "k8s cluster"
    Terraform   = "true"
  } 
# NOTE the file "build_machine_ip.txt" used below is created by  a provisioner inside of VPC resource block

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${file("build_machine_ip.txt")}/32"]
     
    }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${file("build_machine_ip.txt")}/32"]
     
 }
     ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${file("build_machine_ip.txt")}/32"]
     
 }
    ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${file("build_machine_ip.txt")}/32"]
  }
  
    ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.subnet_cidr}"]
  }

  
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
}