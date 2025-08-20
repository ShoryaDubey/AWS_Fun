
data "aws_vpc" "default" {
  default = "true"
}

resource "aws_security_group" "ec2_ssh" {
  name        = "ec2-ssh-nginx"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id  

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open SSH (better restrict to your IP)
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open HTTP for nginx
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "web" {
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = "t2.micro"
  key_name      = "proxy-server"

  vpc_security_group_ids = [aws_security_group.ec2_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF
  tags = {
    Name = "OrderApp"
  }
}

