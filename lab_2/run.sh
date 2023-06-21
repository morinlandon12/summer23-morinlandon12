#!/bin/bash
IMAGE_NAME=lab2
APP_NAME=lab2

cd lab2
rm model_pipeline.pkl

cd trainer
python train.py
mv model_pipeline.pkl ../

# Run pytest within poetry virtualenv
cd ..
poetry install
poetry run pytest -vv -s

# stop and remove image in case this script was run before
docker stop ${APP_NAME}
docker rm ${APP_NAME}

# rebuild and run the new image
echo "Building & running Docker Image"

docker build -t ${IMAGE_NAME} .
docker run -d --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME}
echo "========================================="

#wait for the /health endpoint to return a 200
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

echo -e "testing '/predict' endpoint with string input:"
curl -o /dev/null -s -w "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d\
'{
"MedInc": "y",
"HouseAge": 41.0,
"AveRooms": 6.98412698,
"AveBedrms": 1.02380952,
"Population": 322.0,
"AveOccup": 2.55555556,
"Lat": 37.88,
"Long": -122.23
}'

echo -e "testing '/predict' endpoint with float input:"
curl -o /dev/null -s -w "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d\
'{
"MedInc": 8.3252,
"HouseAge": 41.0,
"AveRooms": 6.98412698,
"AveBedrms": 1.02380952,
"Population": 322.0,
"AveOccup": 2.55555556,
"Lat": 37.88,
"Long": -122.23
}' 

echo -e "testing '/predict' endpoint with missing input:"
curl -o /dev/null -s -w "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d\
'{
"MedInc": 8.3252,
"HouseAge": 41.0,
"AveRooms": 6.98412698,
"Population": 322.0,
"AveOccup": 2.55555556,
"Lat": 37.88,
"Long": -122.23
}'

echo -e "testing '/predict' endpoint with wrong featurename:"
curl -o /dev/null -s -w "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d  '{
            "wrong": 8.3252,
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23
                }' 

echo -e "testing '/predict' endpoint with additional feature:"
curl -o /dev/null -s -w "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d\
'{
"MedInc": 8.3252,
"HouseAge": 41.0,
"AveRooms": 6.98412698,
"AveBedrms": 1.02380952,
"Population": 322.0,
"AveOccup": 2.55555556,
"Lat": 37.88,
"Long": -122.23,
"Additional": 521
}' 

echo -e "testing '/predict' endpoint with invalid value:"
curl -o /dev/null -s -w "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d\
'{
"MedInc": 8.3252,
"HouseAge": 41.0,
"AveRooms": -6.98412698,
"AveBedrms": 1.02380952,
"Population": 322.0,
"AveOccup": 2.55555556,
"Lat": 37.88,
"Long": -122.23
}' 

echo -e "testing '/predict' endpoint with no value:"
curl -o /dev/null -s -w "%{http_code}\n" -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d\
'{
"MedInc": None,
"HouseAge": 41.0,
"AveRooms": 6.98412698,
"AveBedrms": 1.02380952,
"Population": 322.0,
"AveOccup": 2.55555556,
"Lat": 37.88,
"Long": -122.23
}' 

echo -e "========================================="

# Stop and Remove the running container
echo "Stopping the running container"
docker stop ${IMAGE_NAME}

echo "Removing Docker container and image:"
docker rm ${IMAGE_NAME}
docker rmi ${APP_NAME}

