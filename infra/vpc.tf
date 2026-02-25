##########################
##         VPC          ##
##########################

resource "aws_vpc" "buildr_vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "buildr"
  }
}

##########################
##        SUBNETS       ##
##########################

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.buildr_vpc.id
  cidr_block              = "10.0.0.0/25"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "buildr_public"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.buildr_vpc.id
  cidr_block              = "10.0.0.128/25"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "buildr_public"
  }
}

##########################
##   INTERNET GATEWAY   ##
##########################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.buildr_vpc.id
  tags = {
    Name = "buildr_igw"
  }
}

##########################
##     ROUTE TABLES     ##
##########################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.buildr_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "buildr_rt"
  }
}

resource "aws_route_table_association" "public_subnet_1_rt_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_rt_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}
