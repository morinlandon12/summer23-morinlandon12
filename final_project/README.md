# Final Project: Full End-to-End Sentiment Score API

- [Final Project: Full End-to-End Machine Learning API](#final-project-full-end-to-end-machine-learning-api)
  - [API Build Overview](#api-build-overview)
  - [Directory Preview & Local Deployment For Testing](#directory-preview-&-local-deployment-for-testing)
  - [Model Deployment to Azure Kubernetes Services](#model-deployment-to-azure-kubernetes-services)
  - [API Performance and Load Handling](#api-performance-and-load-handling)


## API Build Overview

This is an API which classifies text as either positive or negative and provides the client with a sentiment score between 0 and 1 for user-input text. 

In this build we will:

- Utilize `Poetry` to define our application dependancies
- Package up an existing NLP model ([DistilBERT](https://arxiv.org/abs/1910.01108)) for running efficient CPU-based sentiment analysis from `HuggingFace`
- Create an `FastAPI` application to serve prediction results from user requests
- Test our application with `pytest`
- Utilize `Docker` to package our application as a logic unit of compute
- Cache results with `Redis` to protect our endpoint from abuse
- Deploy our application to `Azure` with `Kubernetes` at morinlandon.mids255.com
- Use `K6` to load test our application
- Use `Grafana` to visualize and understand the dynamics of our system

The `/predict` endpoint expects the following input as an example: 

Expected Input: 
```shell
curl -X 'POST' 'https://morinlandon.mids255.com/predict' \
    -L -H 'Content-Type: application/json' -d \
                '{"text": ["I hate you.", "I love you."]}'
```
And will generate the following output:

Expected Output:
```json
{"predictions":
    [
        [
            {"label":"NEGATIVE","score":0.9006614089012146},{"label":"POSITIVE","score":0.0993385836482048}
        ],
        [
            {"label":"POSITIVE","score":0.9963012933731079},{"label":"NEGATIVE","score":0.0036986342165619135}
        ]
    ]
}

```


## Directory Preview & Local Deployment For Testing
The model files and build scripts may be previewed in this tree diagram: 

```shell
├── Dockerfile
├── README.md
├── azure_login_aks.sh
├── build_push.sh
├── example.py
├── grader.sh
├── infra
│   ├── deployment-pythonapi.yaml
│   ├── deployment-redis.yaml
│   ├── namespace.yaml
│   ├── service-prediction.yaml
│   └── service-redis.yaml
├── load.js
├── mlapi
│   ├── distilbert-base-uncased-finetuned-sst2
│   │   ├── README.md
│   │   ├── config.json
│   │   ├── pytorch_model.bin
│   │   ├── special_tokens_map.json
│   │   ├── tokenizer.json
│   │   ├── tokenizer_config.json
│   │   ├── training_args.bin
│   │   └── vocab.txt
│   ├── poetry.lock
│   ├── pyproject.toml
│   ├── src
│   │   └── main.py
│   └── tests
│       ├── conftest.py
│       ├── test_docs.py
│       └── test_mlapi.py
├── run.sh
└── trainer
    └── train.py
```
The mlapi directory contains the model, as well as the app that builds the model on the FastAPI framework. 

To deploy this locally, the user can run the script ```run.sh```. This will deploy the model to a minikube Kubernetes architecture and the model can be curled at ```http://localhost:8000/predict```. The user may leverage pytest to test the API endpoint by running the following in the mlapi directory:

```shell
poetry run pytest
```

## Model Deployment to Azure Kubernetes Services

The model can be containerized using the shell script ```build_push.sh```. This script builds the Docker container using the Multistage build in the ```Dockerfile``` and pushes the containers to Azure. From there, you can run the ```azure_login_aks.sh``` script to push the containers to Azure Kubernetes Services. This file will reference the kustomize setup in ```.k8s/prod```.

## API Performance and Load Handling

The model performs to project standards with over 75.5 ops/second and a p(99) latency of less than 0.635 seconds.

![Latency and Requests P.1](https://github.com/UCB-W255/summer23-morinlandon12/blob/ac74b6a81e0327210b9db2b547acf82e0aa3bc44/final_project/Screenshot%202023-08-07%20at%209.16.10%20PM.png)

![Latency and Requests P.3](https://github.com/UCB-W255/summer23-morinlandon12/blob/ac74b6a81e0327210b9db2b547acf82e0aa3bc44/final_project/Screenshot%202023-08-07%20at%209.16.21%20PM.png)