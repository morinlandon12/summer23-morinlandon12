# README

## Application

This application is a simple API that allows a user to input their name in a query parameter _?name=_, at the _/hello_ endpoint, to return a JSON object:

        ```{json}
        {
          "message": "hello [name]"
        }
        ```

This API leverages FastAPI, which also allows the client to access OpenAPI documentation at the _/docs_ endpoint, and a json object that meets the OpenAPI v3 specifications at the _/openapi.json_ endpoint. 

The application is containerized using Docker, which is built using a multistage framework. This application can be tested locally using poetry and a pytest framework, or upon deployment using a bash script. 

## How to build the application

This application leverages python 3.11, FastAPI, and Uvicorn, all managed through poetry, which is a dependencies manager. The development and production dependencies can be viewed in the pyproject.toml file. The file tree is as follows: 

```text
.
└── lab_1
   ├─── run.sh
   └─── lab1
      ├── Dockerfile
      ├── README.md
      ├── src
      │   ├── __init__.py
      │   └── main.py
      ├── poetry.lock
      ├── pyproject.toml
      └── tests
         ├── __init__.py
         └── test_lab1.py
```

_src_ contains the application, which is a locally hosted API that prints a personalized greeting message. This app is created with FastAPI, which conveniently creates endpoints for API documentation and an OpenAPI json example. _tests_ contains the pytest framework for testing these endpoints during the development stage. The Dockerfile contains a multistage build that runs the API on a Docker image. The _run.sh_ script tests the endpoints upon deployment as a final unit test. 

To build this, I would recommend first creating the dependencies using pyproject.toml. Next, build the API in the _src_ folder, and write an accompanying test using fastapi.testclient in the _tests_ folder. Following this, create the multistage Docker build in the Dockerfile and build a bash script to run and test the apis. 

## How to run the application

This application can be run locally or through Docker. If running locally, in a terminal, run the following command within the _src_ folder: 

```bash
poetry run uvicorn main:app --reload
```

This will open a port on your local machine, which will allow you to access the API endpoint. Copy the url that is provided to you and paste it into your browser to access the endpoint. Type _/hello?name={Insert Your Name}_ to access the application. You must input an alphanumeric string. No name query or an empty name query parameter will result in a 400 error. Accessing the root domain (i.e. no _/hello_ extension) will result in a 501 error. You may access the API docs at the _/docs_ directory and an OpenAPI json object at _/openapi.json_

Examples of valid queries include:

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

One can also run this API through Docker by building a docker container and image. To do this, you may execute the following commands within the lab_1 directory.

```bash
docker build -t myimage .

docker run -d --name mycontainer -p 8000:8000 myimage
```

You may then access the API via the Docker UI. 


## Testing the API 

Lastly, you may test the endpoints by running in the lab_1 directory:

```bash
poetry run pytest
```

Or by running the _run.sh_ script in the lab_1 directory. 

```bash
./run.sh
```

## Answers to Questions

-[]  What status code should be raised when a query parameter does not match our expectations?

   -[] The 400 error "Bad Request" should be raised as this signifies a client-side error such as invalid syntax, missing query parameters, or unsupported inputs. This code signifies that the client end needs to modify their query to an acceptable format, or expected input type. 

-[] What does Python Poetry handle for us?

   -[] Poetry handles many things, but it's primary purpose is to handle dependencies through the pyproject.toml file and virtual environments so as not to interfere with locally installed packages. Poetry allows for consistency in dev and production environments, since the product is portable and allows for the user to specify and maintain exact dependencies and versions. This allows for less problems with miscommunication among dev teams. 

-[] What advantages do multi-stage docker builds give us?

   -[] Multistage builds allow for efficient memory and space management, because it can more easily cut down on image size if executed properly. Additionally, Multistage builds are easy to read and reuse. Much like poetry environments are portable and reusable, multistage docker builds offer similar functionality within the Docker ecosystem. This allows for consistency among dev teams. 
   


