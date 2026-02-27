#!/bin/bash
set -euo pipefail

INSTANCE_ID="$1"
IMAGE_NAME="$2"
PUBLIC_IP="$3"

if [[ -z "$INSTANCE_ID" ]] || [[ -z "$IMAGE_NAME" ]]; then
	echo "Instance Id or Image Name is not provided.."
	exit 1
fi

echo "Deploy docker container $IMAGE_NAME to EC2 Instance $INSTANCE_ID"

aws ssm send-command \
	--targets "Key=instanceids,Values=$INSTACE_ID" \
	--document-name "AWS-RunShellScript" \
	--comment "Deploying app" \
	--parameters 'commands=[
		"sudo docker rm -f buildr || true",
		"sudo docker run -d --name buildr -p 8000:8000 '$IMAGE_NAME'"
	]'

if [[ -n "$PUBLIC_IP" ]]; then

	echo "Runnig external health check on http://$PUBLIC_IP:8000"

	for i in {1..10}; do
		HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$PUBLIC_IP:8000)

		if [[ "$HTTP_STATUS" == "200" ]]; then
			echo "External health check passed!!!"
			exit 1
		fi
		echo "Waiting for app to become healthy"
		sleep 5
	done

	if [[ "HTTP_STATUS" != "200" ]]; then
		echo "External health check failed."
		exit 1
	fi
fi

echo "App deployment complete."
