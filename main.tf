provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "my-vpc" {
  cidr_block = "192.168.0.0/24"
  tags = {
    Name = "my-vpc"
  }
}
resource "aws_subnet" "pub-sub" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "192.168.0.0/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}
resource "aws_internet_gateway" "my-IGW" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "my-igw"
  }
}
resource "aws_security_group" "public-SG" {
  description = "Allow ssh, http and jenkins"
  vpc_id      = aws_vpc.my-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_route_table" "pub-RT" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-IGW.id
  }
  tags = {
    Name = "pub-rt"
  }
}
resource "aws_route_table_association" "my-pub-association" {
  subnet_id      = aws_subnet.pub-sub.id
  route_table_id = aws_route_table.pub-RT.id
}
resource "aws_instance" "Jenkins-server" {
  subnet_id                   = aws_subnet.pub-sub.id
  ami                         = "ami-0c4f7023847b90238"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  availability_zone           = "us-east-1b"
  /* cpu_core_count = "1"  */
  key_name = "Devops"
  tags = {
    Name = "web_server"
  }
  security_groups = [aws_security_group.public-SG.id]
  user_data       = <<EOF
      #!/bin/bash -xe
      sudo apt update
      sudo apt upgrade -y
      sudo apt  install openssh-server openssh-client -y
      sudo apt-get install software-properties-common
      sudo add-apt-repository ppa:deadsnakes/ppa
      sudo apt-get update
      sudo apt-get install python3.8
      sudo echo "ec2-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
      sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sudo service sshd reload
      sudo apt update
      EOF
}
/* resource "aws_ebs_volume" "new-volume" {
    availability_zone = "us-east-1b"
    size = "50"
} */
/* resource "aws_volume_attachment" "volume-attached" {
  device_name = "/dev/sda1"
  volume_id   = aws_ebs_volume.new-volume.id
  instance_id = aws_instance.Jenkins-server.id */
/* }
resource "aws_key_pair" "Devops" {
    key_name = "Devops"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWXQdEXmpGpp6h7c+a2Y7CE+f/ScyF43lDWQwHptdKKYeLwwVDFBSxTZetpQKqAuOA6sMJCS9Qh/5SPqatZvduID9909W/GklT4Gq+zd77XsvwqLu62twZ+mxe5aFqVR1+BtFy4NUAXNfO+lqtLgYjjqF6j2Y5zEI4ejliXD4nw3JSkVi29RmBqdZQdhpAPfJNFtP+KusXf9MYQPzIpQuxcJT6a+kPRhnZ2k8cFYgD3qxloTRgukPn43qOkGSLTXngfawd65PHFwdimkfqZiHk2gj0RDnjNUoWcoPqm5ce91LyC7sGm1lOKs8bWD/IiQXa01Fev2+1b/S58nVVKKFp Devops"
} */
