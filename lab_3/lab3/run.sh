#!/bin/bash
minikube start --kubernetes-version=v1.25.4 --container-runtime=docker --vm=true

eval $(minikube docker-env)

IMAGE_NAME=lab3
APP_NAME=lab3

# Create poetry environment and train model using environment
# move model to the src directory to be picked up by Docker
poetry env remove python3.11
poetry install

FILE=./model_pipeline.pkl
if [ -f ${FILE} ]; then
    echo "${FILE} exist."
else
    echo "${FILE} does not exist."
    poetry run python ../trainer/train.py
    cp ../trainer/${FILE} .
fi

# Run pytest within poetry virtualenv
poetry run pytest -vv -s

# stop and remove image in case this script was run before
docker stop ${APP_NAME}
docker rm ${APP_NAME}

# rebuild and run the new image
docker build -t ${IMAGE_NAME}:1.0 .
docker run -d --name ${IMAGE_NAME} -p 8000:8000 ${IMAGE_NAME}:1.0

kubectl apply -f infra/namespace.yaml -n w255
kubectl apply -f infra/deployment-redis.yaml -n w255
kubectl apply -f infra/deployment-pythonapi.yaml -n w255
kubectl apply -f infra/service-redis.yaml -n w255
kubectl apply -f infra/service-prediction.yaml -n w255

kubectl wait deployment -n w255 house-deployment --for condition=Available=True --timeout=60s

kubectl port-forward service/prediction -n w255 8000:8000 &


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
echo "Testing hello endpoint for proper input"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/hello?name=Winegar"

echo "Testing hello endpoint for improper query parameter"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/hello?nam=Winegar"

echo "Testing root"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/"

echo "Testing docs"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/docs"

echo "Testing proper input with two houses"
curl -o /dev/null -s -w "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d '{
    "houses": [
        {
            "MedInc": 8.3252,
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23
        },
        {
            "MedInc": 8.3252,
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 50,
            "Long": -122.23
        }
    ]
}'

echo "Testing proper input with one house"
curl -o /dev/null -s -w "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d '{
    "houses": [
        {
            "MedInc": 8.3252,
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23
        }
    ]
}'

echo "Testing bad type"
curl -o /dev/null -s -w "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d '{
    "houses": [
        {
        "MedInc": 1,
        "HouseAge": 2,
        "AveRooms": "I am wrong",
        "AveBedrms": 4,
        "Population": 5,
        "AveOccup": 6,
        "Lat": 7,
        "Long": 8,
        }]}'

echo "Testing missing and extra features"
curl -o /dev/null -s -w "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d '{
    "houses": [
        {
        "MedInc": 1,
        "HouseAge": 2,
        "AveRooms": 3,
        "AveBedrms": 4,
        "Population": 5,
        "AveOccup": 6,
        "Lat": 7,
        "ExtraFeature": 9,
        }]}'



# output logs for the container
docker logs ${APP_NAME}

kubectl delete all --all -n w255

# Delete the w255 namespace
kubectl delete namespace w255

# Stop Minikube
minikube stop
