#!/bin/bash
set -e

INSTANCE_ID="$1"

if [[ -z "$INSTANCE_ID" ]]; then
	echo "Instance Id was not provided. Exiting.."
	exit 1
fi

echo "Installing Docker on EC2 instance $INSTANCE_ID"

aws ssm send-command \
	--targets "Key=instanceids,Values=$INSTANCE_ID" \
	--document-name "AWS-RunShellScript" \
	--comment "Install Docker" \
	--parameters 'commands=[
	  "sudo dnf update -y",
	  "sudo dnf install -y docker",
	  "sudo systemctl enbale docker",
	  "sudo systemctl start docker",
	  "sudo usermod -a -G docker ec2-user"
	]'

echo "Docker install command sent."
