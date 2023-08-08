import pytest
from fastapi.testclient import TestClient

from src import __version__
from src.main import app

client = TestClient(app)


def test_version():
    assert __version__ == "0.2.0"


def test_docs():
    response = client.get("/docs")
    assert response.status_code == 200
