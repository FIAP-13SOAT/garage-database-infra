########################################
# NETWORK - VPC & Subnets (base network for all services)
########################################

resource "aws_vpc" "main" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "${local.projectName}-main-vpc"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "${local.projectName}-igw"
    }
}

########################################
# PUBLIC SUBNETS
########################################

resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "${local.awsRegion}a"
    map_public_ip_on_launch = true
    tags = {
        Name                        = "${local.projectName}-public-subnet"
        "kubernetes.io/role/elb"    = "1"
    }
}

resource "aws_subnet" "public_subnet_b" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.4.0/24"
    availability_zone       = "${local.awsRegion}b"
    map_public_ip_on_launch = true
    tags = {
        Name                        = "${local.projectName}-public-subnet-b"
        "kubernetes.io/role/elb"    = "1"
    }
}

########################################
# PRIVATE SUBNETS
########################################

resource "aws_subnet" "private_subnet" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "${local.awsRegion}a"
    map_public_ip_on_launch = false
    tags = {
        Name                                = "${local.projectName}-private-subnet"
        "kubernetes.io/role/internal-elb"   = "1"
    }
}

resource "aws_subnet" "private_subnet_b" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.3.0/24"
    availability_zone       = "${local.awsRegion}b"
    map_public_ip_on_launch = false
    tags = {
        Name                                = "${local.projectName}-private-subnet-b"
        "kubernetes.io/role/internal-elb"   = "1"
    }
}

########################################
# PUBLIC ROUTING
########################################

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "${local.projectName}-public-rt"
    }
}

resource "aws_route_table_association" "public_a" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
    subnet_id      = aws_subnet.public_subnet_b.id
    route_table_id = aws_route_table.public.id
}

########################################
# NAT GATEWAY
########################################

resource "aws_eip" "nat" {
    domain = "vpc"
}

resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main.id
    }

    tags = {
        Name = "${local.projectName}-private-rt"
    }
}

resource "aws_route_table_association" "private_a" {
    subnet_id      = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
    subnet_id      = aws_subnet.private_subnet_b.id
    route_table_id = aws_route_table.private.id
}
