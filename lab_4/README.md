# README

## Application

This application is an API that allows a user to batch input the following house features to a /predict endpoint in the cloud at https://morinlandon.mids255.com, which will output a house price prediction(s):


        ```{json}
        {"houses":[{
        "MedInc": float,
        "HouseAge": float,
        "AveRooms": float,
        "AveBedrms": float,
        "Population": float,
        "AveOccup": float,
        "Lat": float,
        "Long": float
        }]}
        ```


## Build
The application was built in previous labs, and previous README files may be referenced for local deployments and the build process. In this lab, we deployed the application to the web through Azure Container Services and Azure Kubernetes Services.

First, we build the containerized app using Docker and deploy to ACS. Then we login to AKS, and and leverage kustomize overlays and Istio as a virtual service to deploy the containerized app to AKS. Using these files, we were able to temporarily bypass the YAML files in previous iterations of this lab to create a template for deploying this app to the web. We leveraged the yaml files in the /prod directory to create a production ready deployment of the app on Kubernetes. 

All commands necessary to build and deploy to the web can be found in the following shell scripts. 

```bash
./build_push.sh
```
and 
```bash
./azure_login_aks.sh
```


## Use
The application can be curled at https://morinlandon.mids255.com/predict using the following script:

```bash
curl -X 'POST' 'https://morinlandon.mids255.com/predict' -L -H 'Content-Type: application/json' -d '{"houses": [{ "MedInc": 8.3252, "HouseAge": 42, "AveRooms": 6.98, "AveBedrms": 1.02, "Population": 322, "AveOccup": 2.55, "Lat": 37.88, "Long": -122.23 }]}'
```

## Questions
1. What are the downsides of using latest as your docker image tag?
   - “Latest” means “the last build/tag that ran without a specific tag/version specified. It could point to an unstable or insecure version of the image, so it's best to use a specific tag. 

2. What does kustomize do for us? 
   - Kustomize allows us to temporarily override any previous YAML files that may have been used in development, while preserving those files. It can be useful if you need a different YAML setup for a different type of deployment, like deploying to Azure and AWS, or even just deploying to minikube v. cloud. Just like traditional YAMLs, the kustomize files can be reused for quick and reusable setups. Alongside traditional YAMLs, we can deploy different kustomize setups for different environments. 