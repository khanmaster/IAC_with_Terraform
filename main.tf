provider "aws" {
  region = "eu-west-1"
}

# launch an instance
resource "aws_instance" "app_instance" {
  ami           = "ami-039900c4ef89c6f9c"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  tags = {
      Name = "eng89_shahrukh-terrafrom-app"
  }
   #The key_name to ssh into instance
  key_name = var.aws_key_name
  # aws_key_path = var.aws_key_path
}

# Let's create a VPC  
resource "aws_vpc" "terraform_vpc_code_test" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "eng89_shahrukh_terraform_vpc"
  }
 }



