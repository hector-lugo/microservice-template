resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "xpresso-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "xpresso-igw"
  }
  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "sn-public-1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "xpresso-sn-1-public"
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "sn-public-2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "xpresso-sn-2-public"
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "xpresso-rt-public"
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_route_table_association" "rt-association-public-1" {
  subnet_id = aws_subnet.sn-public-1.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "rt-association-public-2" {
  subnet_id = aws_subnet.sn-public-2.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route" "wm21-route-public" {
  route_table_id = aws_route_table.rt-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_security_group" "service-sg" {
  name = "xpresso-service-sg"
  description = "Simple security group for the service instance"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["74.3.135.94/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "xpresso-service-sg"
  }
}

resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Name = "xpresso-service-eip"
  }
}

data "aws_ami" "aws-ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn-ami-hvm-2018.03.0.20181129-x86_64-gp2"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_instance" "server" {
  ami = data.aws_ami.aws-ami.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.sn-public-1.id

  security_groups = [aws_security_group.service-sg.id]

  user_data = file("./scripts/install.sh")

  key_name = "xpresso-kp"

  tags = {
    Name = "xpresso-server"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.server.id
  allocation_id = aws_eip.eip.id
}
