#Use official Python 3.11
FROM python:3.11-slim as venv

#Security updates
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install curl -y \
    && rm -rf /var/lib/apt/list/*


#Install poetry
ENV POETRY_VERSION=1.4.2
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH=/root/.local/bin:$PATH

#Create venv
RUN python -m venv /venv --copies
#add venv path
ENV PATH=/venv/bin:$PATH

#set working dir
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN . /venv/bin/activate && poetry install --only main

FROM python:3.11-slim as deploy

COPY --from=venv /venv/ /venv/
ENV PATH=/venv/bin:$PATH

WORKDIR /app
COPY . ./

# Expose the port that FastAPI application will be listening on
EXPOSE 8000

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
