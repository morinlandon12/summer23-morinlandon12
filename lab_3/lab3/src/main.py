import numpy as np
from typing import List
import os

from fastapi import FastAPI, Request
from joblib import load
from pydantic import BaseModel, Extra

from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend
from fastapi_cache.decorator import cache

from redis import asyncio as aioredis


app = FastAPI()
PATH = os.getcwd() + '/model_pipeline.pkl'
model = load(PATH)


# Use pydantic.Extra.forbid to only except exact field set from client.
# This was not required by the lab.
# Your test should handle the equivalent whenever extra fields are sent.
class House(BaseModel, extra=Extra.forbid):
    """Data model to parse the request body JSON."""

    MedInc: float
    HouseAge: float
    AveRooms: float
    AveBedrms: float
    Population: float
    AveOccup: float
    Lat: float
    Long: float

    def to_np(self):
        return np.array(list(vars(self).values())).reshape(1,8)

class HouseRequest(BaseModel):
    houses: List[House]

class HousePrediction(BaseModel):
    prediction: List[float]


@app.on_event("startup")
async def startup():
    redis = aioredis.from_url("redis://redis-service.w255")
    FastAPICache.init(RedisBackend(redis), prefix="fastapi-cache")


@app.post("/predict", response_model=HousePrediction)
@cache(expire=3600)
async def predict(house_request: HouseRequest) -> HousePrediction:
    house_inputs = house_request.houses
    n_samples = len(house_inputs)
    house_inputs_np = np.array([house_input.to_np() for house_input in house_inputs]).reshape(n_samples, 8)
    predictions = model.predict(house_inputs_np)
    return HousePrediction(prediction=predictions.tolist())


@app.get("/health")
async def health():
    return {"status": "healthy"}


# Raises 422 if bad parameter automatically by FastAPI
@app.get("/hello")
async def hello(name: str):
    return {"message": f"Hello {name}"}


# /docs endpoint is defined by FastAPI automatically
# /openapi.json returns a json object automatically by FastAPI
