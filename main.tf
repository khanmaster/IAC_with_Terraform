provider "aws" {
	# setting aws region
	region = "eu-west-1"
}

resource "aws_vpc" "terraform_vpc" {
	# creating vpc with chosen cidr
	cidr_block = var.cidr_block
	instance_tenancy = "default"

	tags = {
		Name = var.vpc_name
	}
}
resource "aws_subnet" "eng89_shahrukh_app_subnet" {
	vpc_id = aws_vpc.terraform_vpc.id
	cidr_block = "10.0.1.0/24"
	map_public_ip_on_launch = "true"  # Makes this a public subnet
	availability_zone = "eu-west-1a"

	tags = {
		Name = "eng89_shahrukh_terraform_app"
	}

 }

 resource "aws_security_group" "app_group"  {
  name = "eng89_shahrukh_app_sg_terraform"
  description = "eng89_shahrukh_app_sg_terraform"
  vpc_id = var.vpc_id
# Inbound rules
  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]   
  }
  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]  
  }
ingress {
    from_port       = "3000"
    to_port         = "3000"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]  
  }

# Outbound rules
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eng89_shahrukh_app_sg_terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"


  route{

      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.app.id}"
  }
  tags = {
    Name = "${var.name}-public"
  }
}
# grab a reference to the internet gateway for our VPC
# Route table associations

resource "aws_route_table_association" "assoc" {
  subnet_id      =  "${aws_subnet.eng89_shahrukh_app_subnet.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_internet_gateway" "app" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-IGW"
  }
}


# launch an instance
resource "aws_instance" "app_instance" {
  ami           = var.app_ami_id
  subnet_id     = "${aws_subnet.eng89_shahrukh_app_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.app_group.id}"]
  instance_type = "t2.micro"
  tags = {
      Name = "eng89_shahrukh_pub_app"
  }
  key_name = var.aws_key_name
#   runs commands in instance

provisioner "file" {
  source      = "script.sh"
  destination = "/tmp/script.sh"  
  
  connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.aws_key_path)
      host        = self.public_ip
    }
  }


provisioner "remote-exec" {
  	inline = [
            "chmod +x /tmp/script.sh",
            "sudo /tmp/script.sh",
            # "cd /home/ubuntu/app",
            # "sudo apt-get update -y",
            # "sudo apt-get upgrade -y",
            # "sudo npm install",
            # "sudo seeds/seed.js",
            # "sudo npm start",
  					]
  	connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.aws_key_path)
      host        = self.public_ip
    }
  }
}


