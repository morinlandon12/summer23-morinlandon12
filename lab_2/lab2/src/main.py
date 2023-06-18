from datetime import datetime
import numpy as np

from fastapi import FastAPI, HTTPException
from fastapi.openapi.utils import get_openapi

import joblib

from pydantic import BaseModel, PositiveFloat, ValidationError, root_validator

class UserInput(BaseModel):
    MedInc: PositiveFloat
    HouseAge: PositiveFloat
    AveRooms: PositiveFloat
    AveBedrms: PositiveFloat
    Population: PositiveFloat
    AveOccup: PositiveFloat
    Lat: float
    Long: float

    @root_validator(pre=True)
    def check_input_fields(cls, values):
        missing_fields = [
            field for field, value in values.items()
            if value is None and cls.__fields__[field].required
                         ]
        if missing_fields:
            raise ValueError(f"Missing required input field(s): {', '.join(missing_fields)}")
        return values


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
model_path = '/Users/landon/Documents/GitHub/summer23-morinlandon12/lab_2/lab2/trainer/model_pipeline.pkl'
model = HousingModel(model_path)


@app.get('/hello')
async def get_name(name: str = None):
    if name:
        message = f'Hello {name}'
    elif name == '':
        raise HTTPException(status_code=400, detail = 'empty name parameter')
    else:
        # Not inputting a name is a client error and as such
        # should be accompanied by a 400 error.
        raise HTTPException(status_code = 400, detail = 'missing name parameter')
    return {'message': message}


@app.get('/')
async def root():
    # The request to this endpoint is not to be handled by the server.
    raise HTTPException(status_code = 501, detail = 'not implemented')


@app.post('/predict', response_model=InferenceOutput)
def predict(input: UserInput):
    try:
        output = model.predict(input)
        return output
    except ValueError as e: 
        raise HTTPException(status_code = 422, detail = e)

@app.get('/health')
async def health():
    return {"current datetime": datetime.now().isoformat()}