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