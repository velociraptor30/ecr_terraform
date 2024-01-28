## Creates one Elastic IP per AZ (one for each NAT Gateway in each AZ)

resource "aws_eip" "nat_gateway" {
  count = var.az_count
  vpc   = true

  tags = {
    Name     = "${var.namespace}_EIP_${count.index}_${var.environment}"
  }
}

## Creates one NAT Gateway per AZ

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.az_count
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat_gateway[count.index].id

  tags = {
    Name     = "${var.namespace}_NATGateway_${count.index}_${var.environment}"
  }
}

## One private subnet per AZ

resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.ecr_vpc.id

  tags = {
    Name     = "${var.namespace}_PrivateSubnet_${count.index}_${var.environment}"
  }
}

## Route to the internet using the NAT Gateway

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.ecr_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name     = "${var.namespace}_PrivateRouteTable_${count.index}_${var.environment}"
  }
}

## Associate Route Table with Private Subnets

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.*.id
}
