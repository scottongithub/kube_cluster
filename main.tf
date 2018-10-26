provider "aws" {
/* Credentials are stored/parsed in ~/.aws/credentials, not here
  access_key = "ACCESS_KEY_HERE"
  secret_key = "SECRET_KEY_HERE" */
  region     = "${var.region}"
}

resource "aws_vpc" "k8s" {
  cidr_block                       = "${var.vpc_cidr}"
  instance_tenancy                 = "default"
  enable_dns_hostnames             = "true"
  enable_dns_support               = "true"
  assign_generated_ipv6_cidr_block = "false"
  
  # The provisioner below grabs the public IP of build machine to insert into routing table(s) in secuirty_groups.tf
  provisioner "local-exec" {
    command     = "printf $(curl ifconfig.co) > build_machine_ip.txt"
  }  
  
  tags {
    Name        = "k8s"
    Terraform   = "true"
  }
}


resource "aws_subnet" "public-01" {
  vpc_id                  = "${aws_vpc.k8s.id}"
  availability_zone       = "${var.avail_zone}"
  cidr_block              = "${var.subnet_cidr}"
  map_public_ip_on_launch = true
  tags {
    Name        = "${var.subnet_name}"
    Terraform   = "true"
  }
}


resource "aws_internet_gateway" "this" {
 vpc_id = "${aws_vpc.k8s.id}"
}


resource "aws_route_table" "public" {
 vpc_id = "${aws_vpc.k8s.id}"
 
 tags {
    Name        = "${var.subnet_name}"
    Terraform   = "true"
  }
	
}


resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public-01.id}"
  route_table_id = "${aws_route_table.public.id}"
}



resource "aws_instance" "kub_master" {
  count	= 1
  provisioner "remote-exec" {
    script      = ".//bash/kub_master.sh"
    connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
  key_name                    = "k8s"
  ami                         = "${data.aws_ami.ubuntu.id}" 
  instance_type               = "${var.instance_size}"
# iam_instance_profile        = "${aws_iam_instance_profile.kub_master.name}"
  subnet_id                   = "${aws_subnet.public-01.id}"
  vpc_security_group_ids      = ["${aws_security_group.k8s.id}"]
  associate_public_ip_address = true
  tags {
        Name        = "master"
	Terraform   = "true"
  }
  
}

resource "aws_instance" "kub_worker" {
  count	= 2
  provisioner "remote-exec" {
    script      = ".//bash/kub_worker.sh"
    connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
  key_name                    = "k8s"
  ami                         = "${data.aws_ami.ubuntu.id}" 
  instance_type               = "${var.instance_size}"
  subnet_id                   = "${aws_subnet.public-01.id}"
# iam_instance_profile        = "${aws_iam_instance_profile.kub_worker.name}"
  vpc_security_group_ids      = ["${aws_security_group.k8s.id}"]
  associate_public_ip_address = true
  tags {
        Name        = "worker_node"
	Terraform   = "true"
  }
  
}


resource "aws_key_pair" "deployer" {
  key_name   = "k8s"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}


# Gets the latest Ubuntu 16.04 (LTR) for our EC2 instances
data "aws_ami" "ubuntu" {
  most_recent  = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    owners     = ["099720109477"] # Canonical
}



/*
Load balancer that will take requests at port 80 and translate them into whatever port the service has been exposed on on the kube nodes using the --NodePort option 
*/
/*
resource "aws_eip" "lb" {
  vpc        = true
}

resource "aws_lb" "web" {
  name               = "nginx"
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id     = "${aws_subnet.public-01.id}"
    allocation_id = "${aws_eip.lb.id}"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "web-balancer"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.k8s.id}"
#  target_type = "ip"
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web.arn}"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  count            = 2
  target_group_arn = "${aws_lb_target_group.web.arn}"
# the following strange interpolation is the only way I could get it to work; there is an issue filed in github addressing it
  target_id        = "${element(aws_instance.kub_worker.*.id, count.index)}"
  port             = 32196
}

*/