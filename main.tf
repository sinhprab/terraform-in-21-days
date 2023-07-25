locals {
  public_cidr       = ["10.0.0.0/24", "10.0.1.0/24"]
  private_cidr      = ["10.0.2.0/24", "10.0.3.0/24"]
  availability_zone = ["eu-west-2a", "eu-west-2b"]
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  count = length(local.private_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_cidr[count.index]
  availability_zone = local.availability_zone[count.index]
  
  tags = {
    Name = "public${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = length(local.private_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_cidr[count.index]
  availability_zone = local.availability_zone[count.index]

  tags = {
    Name = "private${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}

resource "aws_eip" "nat" {
  count = length(local.public_cidr)

  vpc = true

  tags = {
    Name = "nat${count.index}"
  }
}

resource "aws_nat_gateway" "main" {
  count = length(local.public_cidr)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "main${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  count = length(local.private_cidr)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "private${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(local.public_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(local.private_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
