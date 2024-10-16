resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev-env"
  }
}


resource "aws_subnet" "my_vpc_public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "my_vpc_public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.my_vpc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_vpc_igw.id
}

resource "aws_route_table_association" "my_vpc_route_association" {
  route_table_id = aws_route_table.my_vpc_public_rt.id
  subnet_id      = aws_subnet.my_vpc_public_subnet.id
}


resource "aws_security_group" "my_vpc_security_grp" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.my_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "vpc_ingress" {
  security_group_id = aws_security_group.my_vpc_security_grp.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "vpc_egress" {
  security_group_id = aws_security_group.my_vpc_security_grp.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


resource "aws_key_pair" "my_vpc_auth" {
  key_name   = "vpc_key"
  public_key = file("~/.ssh/mykey.pub")
}


resource "aws_instance" "dev_instance" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.my_vpc_auth.id
  vpc_security_group_ids = [aws_security_group.my_vpc_security_grp.id]
  subnet_id              = aws_subnet.my_vpc_public_subnet.id
  user_data              = file("userdata.tpl")


  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev_instance"
  }

}