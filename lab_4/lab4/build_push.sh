#!/bin/bash
IMAGE_PREFIX=$(az account list --all | jq '.[].user.name' | grep -i berkeley.edu | awk -F@ '{print $1}' | tr -d '"' | tr -d "." | tr '[:upper:]' '[:lower:]' | tr '_' '-' | uniq)

# FQDN = Fully-Qualified Domain Name
IMAGE_NAME=lab4
ACR_DOMAIN=w255mids.azurecr.io
COMMIT_HASH=$(git rev-parse --short HEAD)
IMAGE_FQDN="$ACR_DOMAIN/$IMAGE_PREFIX/$IMAGE_NAME:$COMMIT_HASH"

az acr login --name w255mids

docker build --platform linux/amd64 -t $IMAGE_NAME:$COMMIT_HASH .

docker tag $IMAGE_NAME:$COMMIT_HASH $IMAGE_FQDN
docker push $IMAGE_FQDN
docker pull $IMAGE_FQDN
