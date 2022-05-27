FROM flant/shell-operator:latest

COPY ./*-hook.sh /hooks/
COPY ./create-ecr-credentials.sh /usr/local/bin/

RUN chmod +x /hooks/create-ecr-credentials-hook.sh \
    /hooks/update-ecr-credentials-hook.sh \
    /usr/local/bin/create-ecr-credentials.sh

RUN apk --no-cache add --no-cache aws-cli
