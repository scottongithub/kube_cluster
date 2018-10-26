
# OVERVIEW
Creates 3 EC2 instances for a Kubernetes cluster and outputs the IPv4 addresses of the instances.  Latest Ubuntu 16.04 AMI with `kubelet`, `kubeadm`, `kubectl`, and `docker.io` installed. Networking restricts all but the necessary traffic to connect to and in between nodes. There is a commented-out network load-balancer to connect to a service that's been exposed via node-port.

# USAGE
Terraform will look in the default location for IAM credentals (`~/.aws/credentials` for linux). It will look at `~/.ssh/rsa_id` and `~/.ssh/rsa_id.pub`for the ssh keys. See `terraform.tfvars` for variables that you may want to view/change.Run `terraform plan`, `terraform apply`, then ssh into nodes as desired with `ssh ubuntu@_node_ip_`. If it is your first time running it from your current external IP, the build will throw an error because the dummy IP (1.2.3.4) from compilation will not match what is being built. Just run `terraform apply` once more. 

# Resources Created
A non-default VPC, a public subnet inside the new VPC, and 3 EC2 images inside of the new subnet: one master node and two workers. 

# Notes
Build machine IP is grabbed at VPC creation and inserted into security group rules, via `curl` and `printf`from bash on build machine; incoming connections are restricted to this address. The instance size is set to t2.small **NOT ON FREE TIER**, changeable in `terraform.tfvars`. I've had ssh timeout while provisioning a node with t2.micro size, not sure if related