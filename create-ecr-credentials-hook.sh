#!/usr/bin/env bash

if [[ $1 == "--config" ]]; then
    cat <<EOF
configVersion: v1
kubernetes:
- apiVersion: v1
  kind: Namespace
  executeHookOnEvent: [ "Added", "Modified" ]
  labelSelector:
    matchLabels:
      $ECR_LABEL_NAME: $ECR_LABEL_VALUE
EOF
else
    NAMESPACE_NAME=$(jr -r '.[0].object.metadata.name $BINDING_CONTEXT_PATH')
    DOCKER_PASSWORD=$(aws ecr get-login-password --region $AWS_REGION)
    SECRET=$(/usr/local/bin/create-ecr-credentials.sh $NAMESPACE_NAME "$DOCKER_PASSWORD")
    # TODO: apply secret
fi
