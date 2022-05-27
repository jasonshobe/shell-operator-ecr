#!/usr/bin/env bash
set -e

NAMESPACE=$1
DOCKER_PASSWORD=$2
DOCKER_REGISTRY_SERVER=$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com
DOCKER_USERNAME=AWS
# DOCKER_PASSWORD=$(aws ecr get-login-password --region $AWS_REGION)
DOCKER_AUTH=$(echo "AWS:$DOCKER_PASSWORD" | base64 -w 0)
DOCKER_CONFIG_JSON=$(echo '{"auths":{"'"$DOCKER_REGISTRY_SERVER"'":{"username":"AWS","password":"'"$DOCKER_PASSWORD"'","auth":"'"$DOCKER_AUTH"'"}}}' | base64 -w 0)

cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $ECR_SECRET_NAME
  namespace: $NAMESPACE
data:
  .dockerconfigjson: $DOCKER_CONFIG_JSON
type: kubernetes.io/dockerconfigjson
EOF
