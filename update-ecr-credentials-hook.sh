#!/usr/bin/env bash

if [[ $1 == "--config" ]]; then
    cat <<EOF
configVersion: v1
schedule:
- crontab: "0 */10 * * *"
  allowFailure: true
EOF
else
    NAMESPACES=$(kubectl get namespaces -o=jsonpath='{.items[?(@.metadata.labels.'"$ECR_LABEL_NAME"'=="'"$ECR_LABEL_VALUE"'")].metadata.name}')
    DOCKER_PASSWORD=$(aws ecr get-login-password --region $AWS_REGION)

    for namespace in $NAMESPACES; do
       /usr/local/bin/create-ecr-credentials.sh $namespace "$DOCKER_PASSWORD" | kubectl apply -f -
    done
fi
