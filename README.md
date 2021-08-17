
## Installing terraform

You can download the binary from the following link:

https://www.terraform.io/downloads.html
When you have unzipped the binary file, there's no installer. 
- should move the file to `/usr/local/bin` directory and set the Path as env var if necessary.


- **For Windows**
- Install Chocolaty

https://chocolatey.org/install
-  we can also install it using chocolatey package managers
- ```Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))```

- Open power shell in Admin mode
- Paste the copied text into your shell and press Enter.
- Wait a few seconds for the command to complete.
- If you don't see any errors, you are ready to use Chocolatey! Type choco or choco -? now, or see Getting Started for usage instructions.

- Install Terraform `choco install terraform`
- Check installation `terraform --version`
- Should see below outcome if everything went well

- `Terraform v1.0.4`

### Let's start with setting up provider as AWS with terraform

```
# launch an instance
resource "aws_instance" "app_instance" {
  ami           = var.app_ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  tags = {
      Name = var.name
  }
   #The key_name to ssh into instance
  key_name = var.aws_key_name
  # aws_key_path = var.aws_key_path
}
```
- vpc- IGW - RT - Subnets - NACLs - SG
# Let's create our VPC
```
resource "aws_vpc" "terraform_vpc_code_test" {
  cidr_block       = var.cidr_block 
  #"10.0.0.0/16"
  instance_tenancy = "default"
  
  tags = {
    Name = var.vpc_name
  }
} 
```
### Let's get into building complete VPC networking

- Starting with our subnet for nodeapp
```terraform
resource "aws_subnet" "eng89_shahrukh_app_subnet" {
	vpc_id = aws_vpc.terraform_vpc.id
	cidr_block = "10.0.1.0/24"
	map_public_ip_on_launch = "true"  # Makes this a public subnet
	availability_zone = "eu-west-1a"

	tags = {
		Name = "eng89_shahrukh_terraform_app"
	}

 }
```

- Creating Security group to allow port 80, 22 and 3000
```
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

# ssh access 
  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]  
  }

# allow port 3000

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
```

- Let's create a route table 
```
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
```
# Route table associations
```
resource "aws_route_table_association" "assoc" {
  subnet_id      =  "${aws_subnet.eng89_shahrukh_app_subnet.id}"
  route_table_id = "${aws_route_table.public.id}"
}
```

- Creating Ingernet gateway to allow internet access to our app
```
resource "aws_internet_gateway" "app" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-IGW"
  }
}
```
- We are all set and ready to launch our app into our new VPC
### Launch the app instance
```

reource "aws_instance" "app_instance" {
  ami           = var.app_ami_id
  subnet_id     = "${aws_subnet.eng89_shahrukh_app_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.app_group.id}"]
  instance_type = "t2.micro"
  tags = {
      Name = var.name
  }
  key_name = var.aws_key_name
  # runs commands in instance
provisioner "remote-exec" {
  	inline = [
            "sudo apt-get update -y", 
  					"cd app",
  					"sudo npm install",
  					"sudo node app.js"
  					]
  	connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.aws_key_path)
      host        = self.public_ip
    }
  }

}
```