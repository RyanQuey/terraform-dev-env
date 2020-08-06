variable "aws_instance_type" {
  type        = string
  description = "instance_type for aws ec2 instance"
}

variable "aws_region" {
  type        = string
  description = "region for aws ec2 instance"
}

provider "aws" {
  version                 = "3.0.0"
  profile                 = "setup-cloud9"
  shared_credentials_file = "/workspace/.aws/credentials"
  region                  = var.aws_region
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloud9_environment_ec2
# TODO set name dynamically
resource "aws_cloud9_environment_ec2" "dev_env" {
  instance_type = var.aws_instance_type
  name          = "dev-env-${var.aws_instance_type}-from-terraform"
  # TODO actually currently is aws linux, and cannot change I don't think
  description = "cloud9 dev env using aws linux, with 16GB Ram and 4 cores"
  tags = {
    Terraform = "true"
  }

  # Run some stuff on the new box
  # currently I'm still using my packer-boxes repo for initializing home config. So just use that 
  # provisioner "remote-exec" {
  #   inline = [
  #     # where I keep my script to setup my home configs. Has some good defaults
  #     # - check out https://github.com/RyanQuey/packer-boxes/tree/master/shared/home-configs for the home configs I use
  #     # - also installs some basic dev tools
  #     # - no need to save the file though; just run it
  #     "curl -L https://raw.githubusercontent.com/RyanQuey/packer-boxes/master/shared/setup-scripts/setup-home-for-new-box.sh | bash"
  #   ]
  # }

  # get instance id from terraform using 
  # provisioner "local-exec" {
  # 	command = "$aws ssm send-command --instance-ids '${element(aws_instance.dev_env.*.id, 0)}' --document-name 'AWS-RunShellScript' --comment 'run command within aws without having to ssh in, by using the aws cli!' --parameters commands='curl -L https://raw.githubusercontent.com/RyanQuey/packer-boxes/master/shared/setup-scripts/setup-home-for-new-box.sh | bash' --output text"
  # }

}

output "id" {
  description = "List of IDs of instances"
  value       = aws_cloud9_environment_ec2.dev_env.*.id
}

