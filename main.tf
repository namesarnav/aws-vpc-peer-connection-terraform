# main.tf

/////---------- VPC 1 (with public and private subnets) -----///
resource "aws_vpc" "vpc_1" {
  cidr_block           = var.vpc_1_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-1"
  }
}

resource "aws_subnet" "vpc_1_pub_subnet" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = var.vpc_1_public_subnet_cidr

  tags = {
    Name = "VPC-1-Public-Subnet"
  }
}

resource "aws_subnet" "vpc_1_private" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = var.vpc_1_private_subnet_cidr

  tags = {
    Name = "VPC-1-Private-Subnet"
  }
}

/////---------- -----------------------------------------////


/////---------- VPC 1 (with public and private subnets) -----///

resource "aws_vpc" "vpc_2" {
  cidr_block           = var.vpc_2_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-2"
  }
}

resource "aws_subnet" "vpc_2_private" {
  vpc_id     = aws_vpc.vpc_2.id
  cidr_block = var.vpc_2_private_subnet_cidr

  tags = {
    Name = "VPC-2-Private-Subnet"
  }
}


# /// 

# So far, just created the VPCs and subnets :') 

# ///


/// ---- (VPC Peering) 
/// Connecting the two VPCs 

resource "aws_vpc_peering_connection" "vpc_1_to_vpc_2" {
  peer_vpc_id = aws_vpc.vpc_2.id #accepteer vpc
  vpc_id      = aws_vpc.vpc_1.id
  auto_accept = true

  tags = {
    Name = "VPC Peering between VPC-1 and VPC-2"
  }
}



//// ------ Now, the functionality part. Attaching the internet gateway to VPC-1 ) -----////

resource "aws_internet_gateway" "vpc_1_igw" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name = "VPC-1-IGW"
  }
}



// -- Route Tables
resource "aws_route_table" "vpc_1_public" {
  vpc_id = aws_vpc.vpc_1.id

  ///Public route table for the public subnet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_1_igw.id
  }

  route {
    cidr_block                = var.vpc_2_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_1_to_vpc_2.id
  }

  tags = {
    Name = "VPC-1-Public-RT"
  }
}

resource "aws_route_table" "vpc_1_private" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block                = var.vpc_2_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_1_to_vpc_2.id
  }

  tags = {
    Name = "VPC-1-Private-RT"
  }
}

resource "aws_route_table" "vpc_2_private" {
  vpc_id = aws_vpc.vpc_2.id

  route {
    cidr_block                = var.vpc_1_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_1_to_vpc_2.id
  }

  tags = {
    Name = "VPC-2-Private-RT"
  }
}

# Route Table Associations
resource "aws_route_table_association" "vpc_1_public" {
  subnet_id      = aws_subnet.vpc_1_pub_subnet.id
  route_table_id = aws_route_table.vpc_1_public.id
}

resource "aws_route_table_association" "vpc_1_private" {
  subnet_id      = aws_subnet.vpc_1_private.id
  route_table_id = aws_route_table.vpc_1_private.id
}

resource "aws_route_table_association" "vpc_2_private" {
  subnet_id      = aws_subnet.vpc_2_private.id
  route_table_id = aws_route_table.vpc_2_private.id
}


///////---------(SECURITY GROUPSSSS)- ----- - ---////

resource "aws_security_group" "nginx" {
  name        = "nginx-sg"
  description = "Security group for nginx host"
  vpc_id      = aws_vpc.vpc_1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-SG"
  }
}

resource "aws_security_group" "private" {
  name        = "private-sg"
  description = "Security group for private instances"
  vpc_id      = aws_vpc.vpc_1.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private-SG"
  }
}

resource "aws_security_group" "vpc_2_private" {
  name        = "vpc-2-private-sg"
  description = "Security group for VPC 2 private instances"
  vpc_id      = aws_vpc.vpc_2.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC-2-Private-SG"
  }
}

# EC2 Instances
resource "aws_instance" "nginx" {
  ami                         = var.ami
  instance_type               = var.nginx_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.vpc_1_pub_subnet.id
  vpc_security_group_ids      = [aws_security_group.nginx.id]
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo yum -y install nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/test-kp.pem")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "nginx-Host"
  }
}

resource "aws_instance" "vpc_1_private" {
  ami           = var.ami
  instance_type = var.private_instance_type
  key_name      = var.key_pair_name

  subnet_id              = aws_subnet.vpc_1_private.id
  vpc_security_group_ids = [aws_security_group.private.id]

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install mongodb",
      "sudo systemctl start mongodb"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/test-kp.pem")
      host        = self.private_ip
    }
  }


  tags = {
    Name = "VPC-1-Private-Instance-Mongo-Host"
  }
}
resource "aws_instance" "vpc_2_private" {
  ami           = var.ami
  instance_type = var.private_instance_type
  key_name      = var.key_pair_name

  subnet_id              = aws_subnet.vpc_2_private.id
  vpc_security_group_ids = [aws_security_group.vpc_2_private.id]

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install mongodb",
      "sudo systemctl start mongodb"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/test-kp.pem") 
      host        = self.private_ip
    }
  }

  tags = {
    Name = "VPC-2-Private-Instance-Mongo"
  }
}
# Outputs
output "nginx_public_ip" {
  value = aws_instance.nginx.public_ip
}

output "vpc_1_private_instance_ip" {
  value = aws_instance.vpc_1_private.private_ip
}

output "vpc_2_private_instance_ip" {
  value = aws_instance.vpc_2_private.private_ip
}

