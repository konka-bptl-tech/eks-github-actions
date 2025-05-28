locals {
  name = "${var.environment}-${var.project_name}"
}
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-vpc"
    }
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-igw"
    }
  )
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-public-subnet-${split("-", var.availability_zone[count.index])[2]}"
    }
  )
}
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-private-subnet-${split("-", var.availability_zone[count.index])[2]}"
    }
  )
}
resource "aws_subnet" "db_subnet" {
  count             = length(var.db_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-db-subnet-${split("-", var.availability_zone[count.index])[2]}"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-public-rt"
    }
  )
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-private-rt"
    }
  )
}
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-db-rt"
    }
  )
}

resource "aws_route_table_association" "publlic" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "db" {
  count          = length(aws_subnet.db_subnet)
  subnet_id      = aws_subnet.db_subnet[count.index].id
  route_table_id = aws_route_table.db.id
}
resource "aws_eip" "example" {
  count  = var.create_nat ? 1 : 0
  domain = "vpc"
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-eip"
    }
  )
}
resource "aws_nat_gateway" "example" {
  count         = var.create_nat ? 1 : 0
  allocation_id = aws_eip.example[count.index].id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-nat-gw"
    }
  )
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
resource "aws_route" "private_nat" {
  count                  = var.create_nat ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.example[count.index].id
}
resource "aws_route" "db_nat" {
  count                  = var.create_nat ? 1 : 0
  route_table_id         = aws_route_table.db.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.example[count.index].id
}

resource "aws_security_group" "allow_all" {
  name        = "allow-all-traffic"
  description = "Security group that allows all inbound and outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-sg"
    }
  )
}


