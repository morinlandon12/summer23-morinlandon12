#!/bin/bash

echo
echo Curl one house prediction
curl -X 'POST' 'https://morinlandon.mids255.com/predict' \
    -L -H 'Content-Type: application/json' -d \
    '{"houses": [{ "MedInc": 8.3252, "HouseAge": 42, "AveRooms": 6.98, "AveBedrms": 1.02, "Population": 322, "AveOccup": 2.55, "Lat": 37.88, "Long": -122.23 }]}'

echo 
echo Curl two house predictions
curl -X 'POST' 'https://morinlandon.mids255.com/predict' \
    -L -H 'Content-Type: application/json' -d \
    '{"houses": [{ "MedInc": 8.3252, "HouseAge": 42, "AveRooms": 6.98, "AveBedrms": 1.02, "Population": 322, "AveOccup": 2.55, "Lat": 37.88, "Long": -122.23 }
                    , { "MedInc": 8.3252, "HouseAge": 42, "AveRooms": 6.98, "AveBedrms": 1.02, "Population": 322, "AveOccup": 2.55, "Lat": 37.88, "Long": -122.23 }]}'
