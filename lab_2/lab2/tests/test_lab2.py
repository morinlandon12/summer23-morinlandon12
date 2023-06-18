from fastapi.testclient import TestClient
import urllib.parse


from src.main import app

client = TestClient(app)

def test_root():
    response = client.get('/')
    assert response.status_code == 501

def test_name():
    name = 'Landon'
    response = client.get(f'/hello?name={name}')
    assert response.json() == {'message': f'Hello {name}'}
    assert response.status_code == 200

def test_no_name():
    response = client.get('/hello')
    assert response.json() == {'detail': 'missing name parameter'}
    assert response.status_code == 400

def test_empty_name():
    name = ''
    response = client.get(f'/hello?name={name}')
    assert response.json() == {'detail': 'empty name parameter'}
    assert response.status_code == 400

def test_special():
    name = "!#$%&'()*+,-./:;<=>?@[\]^_{|}~"
    encoded_name = urllib.parse.quote(name)
    response = client.get(f"/hello?name={encoded_name}")
    assert response.json() == {'message': f"Hello {name}"}    
    assert response.status_code == 200

def test_docs():
    response = client.get('/docs')
    assert response.status_code == 200

def test_open_api():
    response = client.get('/openapi.json')
    assert response.status_code == 200 
    assert '3' in response.json()['openapi']

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

def test_predict_endpoint_incorrect_inputs():
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
