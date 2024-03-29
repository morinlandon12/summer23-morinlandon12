from datetime import datetime
import numpy as np
import os

from fastapi import FastAPI, HTTPException
from fastapi.openapi.utils import get_openapi

import joblib

from pydantic import BaseModel, PositiveFloat, ValidationError, root_validator, validator, confloat, Extra

class UserInput(BaseModel, extra=Extra.forbid):
    MedInc: PositiveFloat
    HouseAge: PositiveFloat
    AveRooms: PositiveFloat
    AveBedrms: PositiveFloat
    Population: PositiveFloat
    AveOccup: PositiveFloat
    Lat: confloat(le=43, ge=32.5)
    Long: confloat(le=-114, ge=-125)

    @root_validator(pre=True)
    def check_input_fields(cls, values):
        missing_fields = [
            field for field, value in values.items()
            if value is None and cls.__fields__[field].required
                         ]
        if missing_fields:
            raise ValueError(f"Missing required input field(s): {', '.join(missing_fields)}")
        return values
    
    @validator("*")
    def validate_my_field(cls, value):
        if isinstance(value, str):
            raise ValueError("my_field must be a float, not a string")
        return value
    

class InferenceOutput(BaseModel):
    Price: PositiveFloat

class HousingModel:
    def __init__(self, model_path):
        self.model_path = model_path
        self.model = self.load_model()

    def load_model(self):
        model = joblib.load(model_path)
        return model
    
    def predict(self, input: UserInput) -> InferenceOutput:
        features = np.array([input.MedInc, input.HouseAge, input.AveRooms, input.AveBedrms, input.Population, 
                             input.AveOccup, input.Lat, input.Long])
        pred = self.model.predict(features.reshape(-1,8))
        pred = {'Price': pred[0]}
        return pred
    

app = FastAPI(openapi_url='/openapi.json', docs_url='/docs')
model_path = 'model_pipeline.pkl'
model = HousingModel(model_path)

@app.get("/hello")
async def hello(name: str):
    return {"message": f"Hello {name}"}


@app.post('/predict', response_model=InferenceOutput)
def predict(input: UserInput):
    output = model.predict(input)
    return output

@app.get('/health')
async def health():
    return {"current datetime": datetime.now().isoformat()}