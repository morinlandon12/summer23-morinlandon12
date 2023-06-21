import pytest
from fastapi.testclient import TestClient
import urllib.parse

from src import __version__
from src.main import app

client = TestClient(app)


def test_version():
    assert __version__ == "0.1.0"


def test_hello_bad_parameter():
    response = client.get("/hello?bob=name")
    assert response.status_code == 422
    assert response.json() == {
        "detail": [
            {
                "loc": ["query", "name"],
                "msg": "field required",
                "type": "value_error.missing",
            }
        ]
    }


def test_root():
    response = client.get("/")
    assert response.status_code == 404
    assert response.json() == {"detail": "Not Found"}


@pytest.mark.parametrize(
    "test_input, expected",
    [("james", "james"), ("bob", "bob"), ("BoB", "BoB"), (100, 100)],
)
def test_hello(test_input, expected):
    response = client.get(f"/hello?name={test_input}")
    assert response.status_code == 200
    assert response.json() == {"message": f"Hello {expected}"}


def test_docs():
    response = client.get("/docs")
    assert response.status_code == 200


def test_hello_multiple_parameter_with_good_and_bad():
    response = client.get("/hello?name=james&bob=name")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello james"}

def test_predict_endpoint_correct_inputs():
    payload =  {
            "MedInc": 8.3252,
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23
                }

    response = client.post("/predict", json=payload)    
    data = response.json()
    assert response.status_code == 200
    assert isinstance(data, dict)
    assert "Price" in data
    assert isinstance(data['Price'], float)


def test_predict_endpoint_incorrect_inputs_type():
    payload =  {
            "MedInc": "eight",
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23
                }
    response = client.post("/predict", json=payload)
    assert response.status_code == 422

def test_predict_endpoint_missing_inputs():
    payload =  {
            "MedInc": 8.3252,
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23
                }
    response = client.post("/predict", json=payload)
    assert response.status_code == 422

def test_predict_improper_field():
    payload =  {
            "wrong": 8.3252,
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23
                }
    response = client.post("/predict", json=payload)
    assert response.status_code == 422

def test_predict_additional_field():
    payload =  {
            "MedInc": 8.3252,
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23,
            "Additional": 521
                }
    response = client.post("/predict", json=payload)
    assert response.status_code == 422

def test_predict_invalid_value():
    payload =  {
            "MedInc": 8.3252,
            "HouseAge": 41.0,
            "AveRooms": -6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23,
                }
    response = client.post("/predict", json=payload)
    assert response.status_code == 422

def test_predict_empty_value():
    payload =  {
            "MedInc": None,
            "HouseAge": 41.0,
            "AveRooms": 6.98412698,
            "AveBedrms": 1.02380952,
            "Population": 322.0,
            "AveOccup": 2.55555556,
            "Lat": 37.88,
            "Long": -122.23,
                }
    response = client.post("/predict", json=payload)
    assert response.status_code == 422

def health_check():
        response = client.get('/health')
        assert response.status_code == 200
        assert isinstance(datetime.fromisoformat(response.json()['time']), datetime)