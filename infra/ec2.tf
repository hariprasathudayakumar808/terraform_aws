resource "aws_security_group" "app_sg" {
  name_prefix = "flask-gpt-sg"
  description = "Allow port 5001 access"
  ingress {
    from_port   = 5001
    to_port     = 5001
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

resource "aws_instance" "app_ec2" {
  ami           = "ami-012a41984655c6c83"
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.app_sg.name]
  iam_instance_profile = "ec2_ssm_role"

  user_data = file("user_data.sh")

  tags = {
    Name = "flask-gpt-ec2"
  }
}
