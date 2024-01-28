provider "aws" {
  region = var.region
}

resource "aws_vpc" "ecr_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name     = "${var.namespace}_VPC_${var.environment}"
  }
}

## Create Internet Gateway for egress/ingress connections to resources in the public subnets

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.ecr_vpc.id

  tags = {
    Name     = "${var.namespace}_InternetGateway_${var.environment}"
  }
}


data "aws_availability_zones" "available" {}