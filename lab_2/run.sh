#!/bin/bash

cd lab2/trainer
rm model_pipeline.pkl
python train.py

cd ..
echo "Building Docker Image"
docker build -t house .
echo "========================================="

# Run built docker image
echo "Running Built Docker Image"
docker run -d --name api-container -p 8000:8000 house
echo "========================================="

sleep 2

# Test Endpoints
echo "Testing Endpoints"
echo "testing '/hello' endpoint with ?name=Landon:"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/hello?name=Landon"

echo "testing '/hello' endpoint with ?name=*()L12:"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/hello?name=*()L12"

echo "testing '/hello' endpoint with ?name=:"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/hello?name="

echo "testing '/hello' endpoint with no name query parameter:"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/hello"

echo "testing '/' endpoint"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/"

echo "testing '/docs' endpoint:"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/docs"

echo "testing '/openapi.json' endpoint:"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/openapi.json"

echo "testing '/predict' endpoint with string input:"
curl -i POST -H "Content-Type: application/json" -d '{
            "MedInc": "y",
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23
                }' http://localhost:8000/predict

echo "testing '/predict' endpoint with float input:"
curl -i POST -H "Content-Type: application/json" -d '{
            "MedInc": 8.3252,
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23
                }' http://localhost:8000/predict

echo "testing '/predict' endpoint with missing input:"
curl -i POST -H "Content-Type: application/json" -d '{
            "MedInc": 8.3252,
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23
                }' http://localhost:8000/predict


echo "========================================="

# Stop and Remove the running container
echo "Stopping the running container"
docker kill api-container

echo "Removing Docker container and image:"
docker rm api-container
docker rmi hello-api

