variable "aws_region" {
  type        = string
  description = "region for aws ec2 instance"
}

provider "aws" {
  profile                 = "setup-cloud9"
  shared_credentials_file = "/workspace/.aws/credentials"
  region                  = var.aws_region
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
