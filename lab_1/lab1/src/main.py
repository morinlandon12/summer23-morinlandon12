from fastapi import FastAPI, HTTPException
from fastapi.openapi.utils import get_openapi

app = FastAPI(openapi_url='/openapi.json', docs_url='/docs')

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
