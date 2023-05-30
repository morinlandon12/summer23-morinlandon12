#!/bin/bash

cd lab1


echo "Building Docker Image"
docker build -t hello-api .
echo "========================================="

# Run built docker image
echo "Running Built Docker Image"
docker run -d --name api-container -p 8000:8000 hello-api
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

echo "========================================="

# Stop and Remove the running container
echo "Stopping the running container"
docker kill api-container

echo "Removing Docker container and image:"
docker rm api-container
docker rmi hello-api

