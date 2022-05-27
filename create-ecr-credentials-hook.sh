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
    NAMESPACE_NAME=$(jq -r '.[0] | select(.object != null) | .object.metadata.name' $BINDING_CONTEXT_PATH)

    if [ ! -z "$NAMESPACE_NAME" ]; then
        DOCKER_PASSWORD=$(aws ecr get-login-password --region $AWS_REGION)
        /usr/local/bin/create-ecr-credentials.sh $NAMESPACE_NAME "$DOCKER_PASSWORD" | kubectl apply -f -
    fi
fi
