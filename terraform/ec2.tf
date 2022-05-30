data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "http" "my_ip" {
  url = "https://ifconfig.me"
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.ec2_key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public1.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = var.project_name
  }
}

resource "aws_security_group" "instance" {
  name   = "${var.project_name}-instance-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    # https://stackoverflow.com/a/53782560
    # https://stackoverflow.com/a/68833352
    cidr_blocks = ["${data.http.my_ip.body}/32"]
  }

  ingress {
    description = "PostgreSQL"
    protocol    = "tcp"
    from_port   = 5433
    to_port     = 5433
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}



