#!/bin/bash
IMAGE_PREFIX=$(az account list --all | jq '.[].user.name' | grep -i berkeley.edu | awk -F@ '{print $1}' | tr -d '"' | tr -d "." | tr '[:upper:]' '[:lower:]' | tr '_' '-' | uniq)

# FQDN = Fully-Qualified Domain Name
IMAGE_NAME=project
ACR_DOMAIN=w255mids.azurecr.io
COMMIT_HASH=$(git rev-parse --short HEAD)
IMAGE_FQDN="$ACR_DOMAIN/$IMAGE_PREFIX/$IMAGE_NAME:$COMMIT_HASH"
az login --tenant berkeleydatasciw255.onmicrosoft.com
az account set --subscription="0257ef73-2cbf-424a-af32-f3d41524e705"
az acr login --name w255mids

#Build in Docker
docker build --platform linux/amd64 -t $IMAGE_NAME:$COMMIT_HASH .

#Tag and push to ACS
docker tag $IMAGE_NAME:$COMMIT_HASH $IMAGE_FQDN
docker push $IMAGE_FQDN
docker pull $IMAGE_FQDN
