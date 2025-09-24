# networking.tf
# Internet Gateway (data lookup) + Public/Private Route Tables + NAT Gateway

# Lookup existing Internet Gateway attached to this VPC
data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [aws_vpc.main.id]
  }
}

# Public route table (routes 0.0.0.0/0 -> existing IGW)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw.id
  }

  tags = {
    Name = "InnovateMart-public-rt"
  }
}

# Associate public route table to public subnets
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IP for NAT Gateway (costly only if NAT exists)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "InnovateMart-NAT-EIP"
  }
}

# NAT Gateway in public subnet 1 (allows private subnets outbound internet)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "InnovateMart-NAT-Gateway"
  }

  # still depends on IGW, but now through data source
  depends_on = [data.aws_internet_gateway.igw]
}

# Private route table (routes 0.0.0.0/0 -> NAT)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "InnovateMart-private-rt"
  }
}

# Associate private route table to private subnets
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}

# Helpful outputs
output "igw_id" {
  value       = data.aws_internet_gateway.igw.id
  description = "Internet Gateway ID (existing)"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat.id
  description = "NAT Gateway ID (may take ~1-2 mins to become available)"
}

output "nat_eip" {
  value       = aws_eip.nat_eip.public_ip
  description = "Elastic IP assigned to NAT Gateway"
}

# Triggering plan run - no resource change

# Triggering plan run - no resource change