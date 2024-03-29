import numpy as np
from typing import List
import os
import logging

from fastapi import FastAPI, Request
from joblib import load
from pydantic import BaseModel, Extra

from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend
from fastapi_cache.decorator import cache

from redis import asyncio as aioredis
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

current_directory = os.getcwd()

model_path = os.path.join(current_directory, "./distilbert-base-uncased-finetuned-sst2")

model = AutoModelForSequenceClassification.from_pretrained(model_path)
tokenizer = AutoTokenizer.from_pretrained(model_path)
classifier = pipeline(
    task="text-classification",
    model=model,
    tokenizer=tokenizer,
    device=-1,
    top_k=None,
)

logger = logging.getLogger(__name__)
AZURE_REDIS_URL = "redis://redis.morinlandon"
app = FastAPI()


@app.on_event("startup")
async def startup():
    redis = aioredis.from_url(AZURE_REDIS_URL)
    FastAPICache.init(RedisBackend(redis), prefix="fastapi-cache")


class SentimentRequest(BaseModel, extra=Extra.forbid):
    text: List[str]
    


class Sentiment(BaseModel):
    label: str
    score: float


class SentimentResponse(BaseModel):
    predictions: List[List[Sentiment]]


@app.post("/predict", response_model=SentimentResponse)
@cache(expire=3600)
async def predict(sentiments: SentimentRequest) -> SentimentResponse:
    return {"predictions": classifier(sentiments.text)}


@app.get("/health")
async def health():
    return {"status": "healthy"}
