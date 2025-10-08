
# Creating internet gateway -----------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.jupiter_main_vpc.id

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}

#Creating 2 Public Subnets -----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "apci_jupiter_public_subnet_az_2a" {
  vpc_id     = aws_vpc.jupiter_main_vpc.id
  cidr_block = var.public_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-2b"
  })
}

resource "aws_subnet" "apci_jupiter_public_subnet_az_2b" {
  vpc_id     = aws_vpc.jupiter_main_vpc.id
  cidr_block = var.public_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-2b"
  })
}

# Creating 2 Private Subnets ----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "apci_jupiter_private_subnet_az_2a" {
  vpc_id     = aws_vpc.jupiter_main_vpc.id
  cidr_block = var.private_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-2a"
  })
}

resource "aws_subnet" "apci_jupiter_private_subnet_az_2b" {
  vpc_id     = aws_vpc.jupiter_main_vpc.id
  cidr_block = var.private_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-2b"
  })
}

#Creating 2 Database subnets ---------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "apci_jupiter_db_subnet_az_2a" {
  vpc_id     = aws_vpc.jupiter_main_vpc.id
  cidr_block = var.db_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-2a"
  })
}

resource "aws_subnet" "apci_jupiter_db_subnet_az_2b" {
  vpc_id     = aws_vpc.jupiter_main_vpc.id
  cidr_block = var.db_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1 ]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-2b"
  })
}

# Creating route table -------------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "apci_jupiter_public_rt" {
  vpc_id = aws_vpc.jupiter_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_rt"
  })
}

#CREATING ROUTE TABLE ASSOCIATION FOR PUBLIC SUBNET-------------------------------------------------------------------------------------------------------------
resource "aws_route_table_association" "apci_jupiter_public_subnet_az_2a" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_az_2a.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

resource "aws_route_table_association" "apci_jupiter_public_subnet_az_2b" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_az_2b.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

# CREATING AN ELASTIC IP FOR AZ 2a NAT GW -----------------------------------------------------------------------------------------------------
resource "aws_eip" "eip_az_2a" {
  domain   = "vpc"
 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az_2a"
  })
}

#CREATING A NAT GATEWAY FOR AZ 2A ------------------------------------------------------------------------------------------------------------
resource "aws_nat_gateway" "apci_jupiter_nat_gw_az_2a" {
  allocation_id = aws_eip.eip_az_2a.id
  subnet_id     = aws_subnet.apci_jupiter_public_subnet_az_2a.id

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-2a"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_2a, aws_subnet.apci_jupiter_public_subnet_az_2a]
}

# CREATING PRIVATE ROUTE TABLE FOR AZ 2A ------------------------------------------------------------------------------------------------------
resource "aws_route_table" "apci_jupiter_private_rt_az_2a" {
  vpc_id = aws_vpc.jupiter_main_vpc.id

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_az_2a.id
  }
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_rt-az-2a"
  })
}

# CREATING PRIVATE ROUTE TABLE ASSOCIATION FOR AZ 2A --------------------------------------------------------------------------------------------
resource "aws_route_table_association" "apci_jupiter_private_subnet_az_2a" {
  subnet_id      = aws_subnet.apci_jupiter_private_subnet_az_2a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_2a.id
}

resource "aws_route_table_association" "apci_jupiter_db_subnet_az_2a" {
  subnet_id      = aws_subnet.apci_jupiter_db_subnet_az_2a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_2a.id
}

# CREATING AN ELASTIC IP FOR AZ 2B NAT GW -----------------------------------------------------------------------------------------------------
resource "aws_eip" "eip_az_2b" {
  domain   = "vpc"
 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az_2b"
  })
}

#CREATING A NAT GATEWAY FOR AZ 2B ------------------------------------------------------------------------------------------------------------
resource "aws_nat_gateway" "apci_jupiter_nat_gw_az_2b" {
  allocation_id = aws_eip.eip_az_2b.id
  subnet_id     = aws_subnet.apci_jupiter_public_subnet_az_2b.id

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-2b"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_2b, aws_subnet.apci_jupiter_public_subnet_az_2b]
}

# CREATING PRIVATE ROUTE TABLE FOR AZ 2B ------------------------------------------------------------------------------------------------------
resource "aws_route_table" "apci_jupiter_private_rt_az_2b" {
  vpc_id = aws_vpc.jupiter_main_vpc.id

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_az_2b.id
  }
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_rt-az-2b"
  })
}

# CREATING PRIVATE ROUTE TABLE ASSOCIATION FOR AZ 2A --------------------------------------------------------------------------------------------
resource "aws_route_table_association" "apci_jupiter_private_subnet_az_2b" {
  subnet_id      = aws_subnet.apci_jupiter_private_subnet_az_2b.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_2b.id
}

resource "aws_route_table_association" "apci_jupiter_db_subnet_az_2b" {
  subnet_id      = aws_subnet.apci_jupiter_db_subnet_az_2b.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_2b.id
}