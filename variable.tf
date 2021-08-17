
# Let's creatge a variable to apply DRY

variable "name" {
  default="Eng89_shahrukh_terraform_app"
}

variable "app_ami_id" {
  default="ami-039900c4ef89c6f9c"
}

variable "vpc_id" {

  default = "vpc-07e47e9d90d2076da"
}
variable "vpc_name" {
  default = "Eng89_shahrukh_terraform_vpc"
}
variable "cidr_block" {
  default="10.0.0.0/16"
}
variable "igw_name" {
  default = "Eng89_shahrukh_terraform_igw"
}

variable "aws_key_name" {

  default = "eng89_devops"
}

variable "aws_key_path" {

  default = "~/.ssh/eng89_devops.pem"
}
