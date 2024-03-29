## One public subnet per AZ

resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.ecr_vpc.id
  map_public_ip_on_launch = true

  tags = {
    Name     = "${var.namespace}_PublicSubnet_${count.index}_${var.environment}"
  }
}

## Route Table with egress route to the internet

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ecr_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name     = "${var.namespace}_PublicRouteTable_${var.environment}"
  }
}

## Associate Route Table with Public Subnets

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

## Make our Route Table the main Route Table

resource "aws_main_route_table_association" "public_main" {
  vpc_id         = aws_vpc.ecr_vpc.id
  route_table_id = aws_route_table.public.id
}