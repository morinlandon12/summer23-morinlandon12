# README

## Application

This application is an API that allows a user to batch input the following house features to a /predict endpoint, which will output a house price prediction(s):


        ```{json}
        {"houses":[{
        "MedInc": PositiveFloat,
        "HouseAge": PositiveFloat,
        "AveRooms": PositiveFloat,
        "AveBedrms": PositiveFloat,
        "Population": PositiveFloat,
        "AveOccup": PositiveFloat,
        "Lat": confloat(le=43, ge=32.5),
        "Long": confloat(le=-114, ge=-125)
        }]}
        ```


Please note that the API /predict endpoint will only handle houses in the state of California, and will return an error for all other lat/long ranges. Additionally, errors will be returned for Median Income, Age of the House, Number of Rooms, Bedrooms, Population, and Occupancy if the inputs are not positive floats, an nested in a dictionary inside of a list whose key is "houses." 
For more information on this dataset, please refer to sklearn's documentation on the California housing dataset [here](https://scikit-learn.org/stable/modules/generated/sklearn.datasets.fetch_california_housing.html).

This API also allows users to pass their names to a /hello endpoint, which will return 

    ```{json}
    {
      "message": "hello [name]"
    }
    ```

This API leverages FastAPI, which also allows the client to access OpenAPI documentation at the _/docs_ endpoint, and a json object that meets the OpenAPI v3 specifications at the _/openapi.json_ endpoint. 

The application is containerized using Docker, which is built using a multistage framework. This application can be tested locally using poetry and a pytest framework, or upon deployment using a bash script. 

## How to build the application

This application leverages python 3.11, Pydantic, FastAPI, and Uvicorn, all managed through poetry, which is a dependencies manager. The development and production dependencies can be viewed in the pyproject.toml file. The file tree is as follows: 

```text
.
├── lab_3
|   ├── lab3
|   |   ├── infra
|   |   |   ├── deployment-pythonapi.yaml
|   |   |   ├── deployment-redis.yaml
|   |   |   ├── namespace.yaml
|   |   |   ├── service-prediction.yaml
|   |   |   └── service-redis.yaml
|   │   ├── Dockerfile
|   │   ├── README.md
|   │   ├── lab3
|   │   │   ├── __init__.py
|   │   │   └── main.py
|   │   ├── model_pipeline.pkl
|   │   ├── poetry.lock
|   │   ├── pyproject.toml
|   │   ├── tests
|   │   │   ├── __init__.py
|   │   │   └── test_lab3.py
|   │   └── trainer
|   │       └── trainer.py
|   └── run.sh
```

_infra_ contains the yaml files that configure the kubernetes deployments and services that run redis and the api. _src_ contains the application, which is a locally hosted API that allows a user to curl or make a request to the /predict endpoint, or receive a personalized greeting message. This app is created with FastAPI, which conveniently creates endpoints for API documentation and an OpenAPI json example. _tests_ contains the pytest framework for testing these endpoints during the development stage. The Dockerfile contains a multistage build that runs the API on a Docker image. The _run.sh_ script tests the endpoints upon deployment as a final unit test. 

To build this with kubernetes, run the following script:

```bash
./run.sh
```

## How to run the application

This application can be run locally, through Docker, or through Kubernetes. If running locally, in a terminal, run the following command within the _src_ folder: 

```bash
poetry run uvicorn main:app --reload
```

This will open a port on your local machine, which will allow you to access the API endpoints. Copy the url that is provided to you and paste it into your browser to access the endpoint to access the browser based application at the /hello endpoint. Type _/hello?name={Insert Your Name}_ to access that application. You must input an alphanumeric string. No name query or an empty name query parameter will result in a 422 error. You may access the API docs at the _/docs_ directory and an OpenAPI json object at _/openapi.json_

Examples of valid queries to the /hello endpoint include:

```bash
http://localhost:8000/hello?name=Landon

http://localhost:8000/hello?name=*L1don

http://localhost:8000/docs

http://localhost:8000/openapi.json
```

The following queries will return exceptions:

```bash
http://localhost:8000/hello?name=

http://localhost:8000/hello

http://localhost:8000/
```

One can also run this API through Kubernetes by building. To do this, you may execute the following commands within the lab_3 directory.

```bash
./run.sh
```

This will run the API through Kubernetes, and will forward port to your local machine. But will also shut down the container and image. If you need to access the API for longer, I suggest running all commands up to and including:

```bash
kubectl port-forward service/prediction -n w255 8000:8000 &
```

With the forwarded port, copy and paste _localhost:8000_ into your browser to access the _/hello_ endpoint and docs, or curl the _/predict_ endpoint to run predictions.

The /predict endpoint will take specific datatypes (listed in the Application section of this file). Any deviation from these types, additional features, or fewer inputted features will result in 422 errors and an unsuccessful attempt to predict.

One can make a successful POST to the /predict endpoint by writing the following script in bash: 


```bash
curl -X POST -H "Content-Type: application/json" -d '{"houses": [{
    "MedInc": 8.3252,
    "HouseAge": 41.0,
    "AveRooms": 6.98412698,
    "AveBedrms": 1.02380952,
    "Population": 322.0,
    "AveOccup": 2.55555556,
    "Lat": 37.88,
    "Long": -122.23
}]}' http://127.0.0.1:8000/predict
```

## Testing the API 

Lastly, you may test the endpoints by running in the lab_3 directory:

```bash
poetry run pytest
```

Or by running the _run.sh_ script in the lab_3 directory. 

```bash
./run.sh
```

## Answers to Questions

-[]  What are the benefits of caching?

   -[] Caching an API endpoint improves the performance of the app or page, since repeated actions are stored locally. This improves web page load times and/or app performance through lower latency. Additionally, caching reduces the load on the server because fewer requests need to be made to slower storage systems like disk or network-based systems. Lastly, this translates into potentially greater efficiencies, which include, but are not limited to cost efficiencies and environmental efficiencies. Because caching requires fewer heavy requests, this translates to potentially lower costs and lower emissions. 

-[] What is the difference between docker and k8s?

   -[] Docker is a containerization platform that allows developers to deploy and create microservices within containers. Kubernetes is a platform that automates the deployment, scaling, and management of these applications across cluster computing. K8s allows for the scaling of microservices. When more compute is needed, K8s can scale up new pods to run the microservices with more power. 

-[] What does a Kubernetes Deployment do? 

   -[] Kubernetes deployments manage the deployment of containerized apps. They can be used to create, update, and delete apps, and they can also be used for horizontal or vertical scaling, if more compute is needed. Importantly, they can monitor the health of pods and apps, and restart pods that fail. Deployments can also reroute traffic to healthy pods if needed. 

-[] What does a Kubernetes Services do? 
   -[] Kubernetes services are an abstraction that defined a grouping of pods that are deployed by Kubernetes. The grouping of pods share the same purpose, and the service layer helps with the communication and load balancing amongst those pods. Pods can be exposed to the internet with the LoadBalancer service, or can be accessible only within the cluster with the ClusterIP service. In this lab, I utilized the clusterIP service since we are not deploying to the internet. 
