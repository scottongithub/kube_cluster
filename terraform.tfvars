# Region to be run in
region = "us-east-1"

# Availability zone of the new subnet
avail_zone = "us-east-1a" 

# CIDR Block of the new VPC
vpc_cidr = "10.0.10.0/24"

# CIDR block of the new subnet inside the new VPC
subnet_cidr = "10.0.10.0/28"

# AWS Name of new subnet inside new VPC. 
subnet_name = "Public-01"

# All instances will be this size
instance_size = "t2.small"
