resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.app_name}-igw"
  }
}


resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.app_name}-rt-public"
  }
}

resource "aws_default_route_table" "rt_private" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name = "${var.app_name}-rt-private"
  }
}

data "aws_availability_zones" "azs" {}

resource "aws_subnet" "public_subnets" {
  count = 2
  cidr_block = "10.0.${4 * count.index + 1}.0/24"
  vpc_id = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "10.0.3.0/24"
  vpc_id     = aws_vpc.vpc.id
  tags = {
    Name = "${var.app_name}-private"
  }
}


resource "aws_route_table_association" "public-rt-association" {
  count = 2
  route_table_id = aws_route_table.rt_public.id
  subnet_id = aws_subnet.public_subnets.*.id[count.index]
}

# Associate the private subnets with the public route table
resource "aws_route_table_association" "private-rt-association" {
  route_table_id = aws_route_table.rt_public.id
  subnet_id      = aws_subnet.private_subnet.id
}

resource "aws_security_group" "public-sg" {
  name        = "public-group-default"
  description = "access to public instances"
  vpc_id      = aws_vpc.vpc.id
}

# create security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-group"
  description = "control access to the application load balancer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
}

# create security group to access the ecs cluster (traffic to ecs cluster should only come from the ALB)
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-from-alb-group"
  description = "control access to the ecs cluster"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 8888
    to_port         = 8888
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
