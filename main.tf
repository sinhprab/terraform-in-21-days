resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-1"
  tags = {
    Name = "Public01"
  }
}

resource "aws_subnet" "public02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2"
  tags = {
    Name = "Public02"
  }
}

resource "aws_subnet" "private01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1"
  tags = {
    Name = "Private01"
  }
}

resource "aws_subnet" "private02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2"
  tags = {
    Name = "Private02"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Main"
  }
}

resource "aws_eip" "nat01" {
  vpc = true
  tags = {
    Name = "Nat01"
  }
}

resource "aws_eip" "nat02" {
  vpc = true
  tags = {
    Name = "Nat02"
  }
}

resource "aws_nat_gateway" "main01" {
  allocation_id = aws_eip.nat01.id
  subnet_id     = aws_subnet.public01.id

  tags = {
    Name = "Main01"
  }
}

resource "aws_nat_gateway" "main02" {
  allocation_id = aws_eip.nat02.id
  subnet_id     = aws_subnet.public02.id

  tags = {
    Name = "Main02"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public"
  }
}

resource "aws_route_table" "private01" {
  vpc_id = aws_vpc.main.id

  route = {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main01.id
  }

  tags = {
    Name = "Private01"
  }
}

resource "aws_route_table" "private02" {
  vpc_id = aws_vpc.main.id

  route = {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main02.id
  }

  tags = {
    Name = "Private02"
  }
}

resource "aws_route_table_association" "public01" {
  subnet_id      = aws_subnet.public01.id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "public02" {
  subnet_id      = aws_subnet.public02.id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "private01" {
  subnet_id      = aws_subnet.private01.id
  route_table_id = aws_route_table.private01.id

}

resource "aws_route_table_association" "private02" {
  subnet_id      = aws_subnet.private02.id
  route_table_id = aws_route_table.private02.id

}
