
# OVERVIEW
Creates 3 EC2 instances for a Kubernetes cluster and outputs the IPv4 addresses of the instances.  Latest Ubuntu 16.04 AMI with `kubelet`, `kubeadm`, `kubect`l, and `docker.io` installed. Networking restricts all but the necessary traffic to connect to and in between nodes. 

# USAGE
Terraform will look in the default location for IAM credentals (`~/.aws/credentials for linux`). It will look at `~/.ssh/rsa_id` and `~/.ssh/rsa_id.pub`for the ssh keys. See `terraform.tfvars` for variables that you may want to view/change. Run `terraform plan`, `terraform apply`, then ssh into nodes as desired with `ssh ubuntu@__node_ip__.

# Resources Created
A non-default VPC, a public subnet inside the new VPC, and 3 EC2 images inside of the new subnet: one master node and two workers. 

# Notes
Build machine IP is grabbed at VPC creation and inserted into routing tables; incoming connections are restricted to this address. The instance size is set to t2.small **NOT ON FREE TIER**, changeable in `terraform.tfvars`. I've had ssh timeout on a node a few times, possibly due to the 