#!/bin/bash -eux

if [ "$BASH" != "/bin/bash" ]; then
  echo "Please do ./$0"
  exit 1
fi

# always base everything relative to this file to make it simple
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

# these should be the same as the instance you want to take down
aws_region=us-west-2
aws_instance_type=t3.xlarge

terraform="docker run -it -v $parent_path:/workspace -w /workspace hashicorp/terraform:light"
$terraform destroy \
  -var="aws_region=$aws_region" \
  -var="aws_instance_type=$aws_instance_type"

