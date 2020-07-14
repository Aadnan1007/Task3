provider "aws" {
    region ="ap-south-1"
    profile = "adnanshk"
    access_key = "$EnterAccessKey"
    secret_key = "$EnterSecretKey"
  
}
resource "aws_vpc" "adnanskvpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames  = true

  tags = {
    Name = "adnanvpc"
  }
}
resource "aws_subnet" "public" {
  vpc_id     = "vpc-0fe0367bacf368edf"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "adnanpublicsubnet"
  }
}
resource "aws_subnet" "private" {
  vpc_id     = "vpc-0fe0367bacf368edf"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "adnanprivatesubnet"
  }
}
resource "aws_internet_gateway" "adnangw" {
  vpc_id = "vpc-0fe0367bacf368edf"

  tags = {
    Name = "adnanig"
  }
}
resource "aws_route_table" "forig" {
  vpc_id = "vpc-0fe0367bacf368edf"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0a776fa23fe83fe5a"
  }

  tags = {
    Name = "adnanigroutetable"
  }
}
resource "aws_route_table_association" "associatetopublic" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.forig.id
}
resource "aws_security_group" "webserver" {
  name        = "for_wordpress"
  description = "Allow hhtp,ssh"
  vpc_id      = "vpc-0fe0367bacf368edf"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver_sg"
  }
}
resource "aws_security_group" "database" {
  name        = "for_MYSQL"
  description = "Allow ssh and MYSQL"
  vpc_id      = "vpc-0fe0367bacf368edf"

  ingress {
    description = "MYSQL"
    security_groups = [aws_security_group.webserver.id]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wpdatabase_sg"
  }
}
resource "aws_instance" "WordPress" {
    ami = "ami-7e257211"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    subnet_id = "subnet-0233c429c1301ff17"
    key_name = "$EnterYourKey"
    vpc_security_group_ids = [ "sg-02faee22b1fc8ca7b"  ]
    tags = {
        Name = "WordPressServer"
    }
}

resource "aws_instance" "mysql_inst" {
    ami = "ami-07a8c73a650069cf3"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    subnet_id = "subnet-0a7b98909c6d6f77f"
    key_name = "$EnterYorKey"
    vpc_security_group_ids = [ "sg-037537e169f4937fa" ]
    tags = {
        Name = "WordPressDB"
    }
}
