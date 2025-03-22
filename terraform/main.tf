terraform {
    backend "remote" {
        organization = "bourbonandrye11"
        workspaces {
            name = "actions"
        }
    }
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

# create a VPC
# create a public subnet
# create an IGW
# create a route table
# create a route and association
# create a security group
# create an EC2 instance

resource "aws_vpc" "tf_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "tf_vpc"
    }
}

resource "aws_subnet" "tf_public_subnet" {
    vpc_id = aws_vpc.tf_vpc.id
    count = length(var.public_subnet_cidrs)
    cidr_block = element(var.public_subnet_cidrs, count.index)
    availability_zone = element(var.aws_azs, count.index)

    tags = {
        Name = "tf_public_subnet"
    }
}

resource "aws_subnet" "tf_private_subnet" {
    vpc_id = aws_vpc.tf_vpc.id
    count = length(var.private_subnet_cidrs)
    cidr_block = element(var.private_subnet_cidrs, count.index)
    availability_zone = element(var.aws_azs, count.index)

    tags = {
        Name = "tf_private_subnet"
    }
}

resource "aws_internet_gateway" "tf_igw" {
    vpc_id = aws_vpc.tf_vpc.id

    tags = {
        Name = "tf_igw"
    }
}

resource "aws_route_table" "tf_public_route_table" {
    vpc_id = aws_vpc.tf_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tf_igw.id
    }

    tags = {
            Name = "tf_public_route_table"
    }
}

resource "aws_route_table" "tf_private_route_table" {
    vpc_id = aws_vpc.tf_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tf_igw.id
    }

    tags = {
            Name = "tf_public_route_table"
    }
}

resource "aws_route_table_association" "tf_public_subnet_association" {
    count = length(var.public_subnet_cidrs)
    subnet_id = element(aws_subnet.tf_public_subnet[*].id, count.index)
    route_table_id = aws_route_table.tf_public_route_table.id
    depends_on = [ aws_subnet.tf_public_subnet ]
}

resource "aws_security_group" "tf_security_group" {
    vpc_id = aws_vpc.tf_vpc.id
    name = "tf_security_group"
    description = "Open 80, and 22 from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "tf_security_group_ingress" {
    security_group_id = aws_security_group.tf_security_group.id
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr_ipv4 = "10.0.0.0/8"
}

resource "aws_vpc_security_group_ingress_rule" "tf_security_group_ingress_ssh" {
    security_group_id = aws_security_group.tf_security_group.id
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr_ipv4 = "10.0.0.0/8"
}

resource "aws_vpc_security_group_egress_rule" "tf_security_group_egress" {
    security_group_id = aws_security_group.tf_security_group.id
    ip_protocol = "tcp"
    from_port = 0
    to_port = 0
    cidr_ipv4 = "0.0.0.0/8"
}

data "aws_ami" "amazon-linux-2" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm*"]
    }
}

data "aws_subnet" "subnets_in_az" {
    vpc_id = aws_vpc.tf_vpc.id
    availability_zone = "us-east-1a"
}

resource "aws_instance" "tf_instance" {
    ami = data.aws_ami.amazon-linux-2.id
    subnet_id = data.aws_subnet.subnets_in_az.id
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.tf_security_group.id]
    metadata_options  {
        http_tokens = "required"
    }

    root_block_device {
        delete_on_termination = true
        volume_size = 8
        encrypted = true
        volume_type = "gp3"
    }

}