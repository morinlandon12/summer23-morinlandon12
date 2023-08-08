#!/bin/bash
minikube start --kubernetes-version=v1.25.4 --container-runtime=docker --vm=true

IMAGE_NAME=project
APP_NAME=project
NAMESPACE=morinlandon

kubectl config use-context minikube
kubectl config set-context --current --namespace=${NAMESPACE}

eval $(minikube docker-env)

# Run pytest within poetry virtualenv
cd mlapi
poetry env remove python3.11
poetry install
poetry run pytest -vv -s

# stop and remove image in case this script was run before
docker stop ${APP_NAME}
docker rm ${APP_NAME}

cd ..
# rebuild and run the new image
docker build --platform linux/amd64 -t ${IMAGE_NAME} .
docker run -d --name ${IMAGE_NAME} -p 8000:8000 ${IMAGE_NAME}:latest

kubectl kustomize .k8s/base
kubectl apply -f .k8s/base

kubectl wait deployment -n morinlandon project --for condition=Available=True --timeout=60s

kubectl port-forward service/project -n morinlandon 8000:8000 &


#wait for the /health endpoint to return a 200
sleep 5
finished=false
while ! $finished; do
    health_status=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/health")
    if [ $health_status == "200" ]; then
        finished=true
        echo "API is ready"
    else
        echo "API not responding yet"
        sleep 1
    fi
done


# check a few endpoints and their http response
curl -o /dev/null -s "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d '{"text": ["I hate you.", "I love you."]}'



# output logs for the container
docker logs ${APP_NAME}

kubectl delete all --all -n morinlandon

# Delete the morinlandon namespace
kubectl delete namespace morinlandon

# Stop Minikube
minikube stop
