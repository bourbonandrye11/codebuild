variable "aws_azs" {
    type = list(string)
    description = "A list of availability zones in the region"
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
    type = list(string)
    description = "A list of CIDR blocks for the public subnets"
    default = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "private_subnet_cidrs" {
    type = list(string)
    description = "A list of CIDR blocks for the public subnets"
    default = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
}
