#!/bin/bash
minikube start --kubernetes-version=v1.25.4 --container-runtime=docker --vm=true

eval $(minikube docker-env)

IMAGE_NAME=final_mini
APP_NAME=final_mini

# Create poetry environment and train model using environment
# move model to the src directory to be picked up by Docker
poetry env remove python3.11
poetry install

# Run pytest within poetry virtualenv
cd mlapi
poetry run pytest -vv -s

# stop and remove image in case this script was run before
docker stop ${APP_NAME}
docker rm ${APP_NAME}

cd ..
# rebuild and run the new image
docker build -t ${IMAGE_NAME}:1.0 .
docker run -d --name ${IMAGE_NAME} -p 8000:8000 ${IMAGE_NAME}:1.0

kubectl apply -f infra/namespace.yaml -n final-proj
kubectl apply -f infra/deployment-redis.yaml -n final-proj
kubectl apply -f infra/deployment-pythonapi.yaml -n final-proj
kubectl apply -f infra/service-redis.yaml -n final-proj
kubectl apply -f infra/service-prediction.yaml -n final-proj

kubectl wait deployment -n final-proj sentiment-deployment --for condition=Available=True --timeout=60s

kubectl port-forward service/prediction -n final-proj 8000:8000 &


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

kubectl delete all --all -n final-proj

# Delete the final-proj namespace
kubectl delete namespace final-proj

# Stop Minikube
minikube stop
