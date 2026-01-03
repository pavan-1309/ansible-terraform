provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = "ami-02b8269d5e85954ef"
  key_name = "my-keypair"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-0a0ee2d6bfc36780f"]
  
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y python3
  EOF
  
  tags = {
    Environment = var.environment
    Role        = "web"
    Name        = "${var.environment}-web-${count.index + 1}"
  }
}
