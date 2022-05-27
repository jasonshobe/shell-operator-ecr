# shell-operator-ecr

*Shell-operator ECR* is a set of hooks for [Shell-operator](https://github.com/flant/shell-operator) that automate the creating and updating of Docker registry secrets for an AWS Elastic Container Registry (ECR) private Docker registry. Any namespace with a matching label will automatically have a secret created in it with the ECR credentials. All existing secrets will be updated every 10 hours to ensure that none are expired.

## Installation

Create a namespace and RBAC objects for the operator.

```shell
kubectl create namespace ecr-credentials
kubectl create serviceaccount ecr-credentials-acc --namespace ecr-credentials
kubectl create clusterrole ecr-credentials --verb=get,watch,list --resource=namespaces
kubectl create clusterrolebinding ecr-credentials --clusterrole=ecr-credentials --serviceaccount=ecr-credentials:ecr-credentials-acc
```

Create a secret with the variables that will be used by the operator:

```shell
kubectl create secret generic ecr-credentials \
    --from-literal=AWS_ACCOUNT=123456789012 \
    --from-literal=AWS_REGION=us-east-1 \
    --from-literal=AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
    --from-literal=AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
    --from-literal=ECR_SECRET_NAME=ecr-credentials \
    --from-literal=ECR_LABEL_NAME=useEcrCredentials \
    --from-literal=ECR_LABEL_VALUE=true
```

The variables are described in the following table:

| Variable              | Description                                                                              |
| --------------------- | ---------------------------------------------------------------------------------------- |
| AWS_ACCOUNT           | Your AWS account number                                                                  |
| AWS_REGION            | The AWS region that your private registry is in                                          |
| AWS_ACCESS_KEY_ID     | Your AWS access key ID                                                                   |
| AWS_SECRET_ACCESS_KEY | Your AWS secret access key                                                               |
| ECR_SECRET_NAME       | The name of the secret that will be created in labeled namespaces                        |
| ECR_LABEL_NAME        | The name of the label that identifies the namespaces that require ECR credential secrets |
| ECR_LABEL_VALUE       | The value fo the label that identifies the namespaces                                    |

The ECR Shell-operator can be deployed as a Pod. Put this manifest into the `shell-operator-ecr.yaml` file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shell-operator-ecr
spec:
  containers:
  - name: shell-operator-ecr
    image: ghcr.io/jasonshobe/shell-operator-ecr:latest
    imagePullPolicy: Always
    envFrom:
    - secretRef:
        name: ecr-credentials
  serviceAccountName: ecr-credentials-acc
```

Start the operator by applying the `shell-operator-ecr.yaml` file:

```shell
kubectl -n ecr-credentials apply -f shell-operator-ecr.yaml
```

Now if you create a namespace with the configured label, a Docker registry secret for your ECR registry will be created in it. The secret will be automatically updated every 10 hours.

```shell
kubectl create namespace example
kubectl label namespace example useEcrCredentials=true
kubectl get secrets -n example
```
