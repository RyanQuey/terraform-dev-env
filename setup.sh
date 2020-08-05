#!/bin/bash -eux

if [ "$BASH" != "/bin/bash" ]; then
  echo "Please do ./$0"
  exit 1
fi

# TODOs
# - use ansible for this instead of bash script?



# always base everything relative to this file to make it simple
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

#####################################
# SETUP AWS
#####################################

# make this dir if doesn't exist. 
# This will be used in our aws-cli docker container's .aws dir using docker volumes, as recommended in aws instructions https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-docker.html
mkdir -p $parent_path/.aws
aws_cli="docker run --rm -it -v $parent_path/.aws:/root/.aws amazon/aws-cli"

# get thedocker image for aws cli. Use docker, so can run this on windows or linux or anything that runs docker
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-docker.html

# region sets default, but can be overwritten in terraform anyways
# output format default is set to json, no real reason why though. But will make setting up faster if there's some default 
# don't want to use host's .aws file, don't want to touch that. Also allows for greater compatibillity between Windows and Linux hopefully
# at the same time, if they do want to use this profile for later, it's already namespaced for this program, so could just merge what's here into their ~/.aws dir if they want to

# technically, can skip this since we have the config set in git. 
# But, for now we want to .gitignore that. So if running the first time UNCOMMENT THESE
# Also, if we change a var in this file, want that to be reflected in the aws cli profile too
# $aws_cli configure set profile.setup-cloud9.region us-west-2
# $aws_cli configure set profile.setup-cloud9.output json

# allow user to put in their credentials
$aws_cli configure --profile setup-cloud9

#####################################
# SETUP TERRAFORM
#####################################
# see here for their docker setup: https://github.com/hashicorp/terraform/blob/master/scripts/docker-release/Dockerfile-release
# tutorial: 
# https://www.vic-l.com/terraform-with-docker/
#
# it's on alpine, so start shell using: 
# docker run -it --entrypoint="/bin/ash" hashicorp/terraform:light

terraform="docker run -it -v $parent_path:/workspace -w /workspace hashicorp/terraform:light"

# verify installation
# TODO set a version? e.g., docker pull hashicorp/terraform:0.12.29
# NOTE don't need to call `terraform` command. E.g., don't do `terraform init`, just do `init`
$terraform init
$terraform fmt
$terraform validate

$terraform plan aws-cloud9.tf
