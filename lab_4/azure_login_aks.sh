#!/bin/bash
IMAGE_NAME=lab4
APP_NAME=lab4
NAMESPACE=$(az account list --all | jq '.[].user.name' | grep -i berkeley.edu | awk -F@ '{print $1}' | tr -d '"' | tr -d "." | tr '[:upper:]' '[:lower:]' | tr '_' '-' | uniq)
SHORT_COMMIT_HASH=$(git rev-parse --short HEAD)

az login --tenant berkeleydatasciw255.onmicrosoft.com
az account set --subscription="0257ef73-2cbf-424a-af32-f3d41524e705"
az aks get-credentials --name w255-aks --resource-group w255 --overwrite-existing
kubectl config use-context w255-aks
kubectl config set-context --current --namespace=${NAMESPACE}
kubectl config view --minify | grep namespace

sed "s/\[TAG\]/${SHORT_COMMIT_HASH}/g" .k8s/prod/patch-deployment-lab4_copy.yaml > .k8s/prod/patch-deployment-lab4.yaml

kubectl kustomize .k8s/prod
kubectl apply -k .k8s/prod

az acr login --name w255mids
