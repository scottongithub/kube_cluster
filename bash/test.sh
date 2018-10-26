

sudo hostnamectl set-hostname $(curl http://169.254.169.254/latest/meta-data/local-hostname)

sudo nano /etc/systemd/system/kubelet.service.d/10-kubeadm.conf 

#sudo kubeadm config images pull

sudo kubeadm init

#Set /proc/sys/net/bridge/bridge-nf-call-iptables to 1
sudo sysctl net.bridge.bridge-nf-call-iptables=1

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

nano nginx-deployment.yaml

kubectl apply -f nginx-deployment.yaml

nano nginx-service.yaml

kubectl apply -f nginx-service.yaml 



kubectl expose deployment hello-world --type=LoadBalancer --name=my-service






#################
# Create and attach IAM policies for API server (master node) to request/maintain infra
#################

resource "aws_iam_role_policy" "kub_master" {
  name = "master-policy"
  role = "${aws_iam_role.kub_master.id}"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "elasticloadbalancing:*","ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:GetRepositoryPolicy", "ecr:DescribeRepositories", "ecr:ListImages", "ecr:BatchGetImage", "autoscaling:DescribeAutoScalingGroup", "autoscaling:UpdateAutoScalingGroup", "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "kub_master" {
  name = "master-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [

    {
     "Action": "sts:AssumeRole",
     "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "kub_master" {
  name = "master-profile"
  role = "${aws_iam_role.kub_master.name}"
}

#################
# Create and attach IAM policies for worker nodes to communicate with AWS
#################

resource "aws_iam_role_policy" "kub_worker" {
  name = "worker-policy"
  role = "${aws_iam_role.kub_worker.id}"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*", "ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:GetRepositoryPolicy", "ecr:DescribeRepositories", "ecr:ListImages", "ecr:BatchGetImage"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "kub_worker" {
  name = "worker-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [

    {
     "Action": "sts:AssumeRole",
     "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "kub_worker" {
  name = "worker-profile"
  role = "${aws_iam_role.kub_worker.name}"
}


#################
# Create one non-default VPC
#################




/etc/systemd/system/kubelet.service.d/10-kubeadm.conf file, adding the --cloud-provider=aws --cloud-config=/etc/kubernetes/cloud.conf