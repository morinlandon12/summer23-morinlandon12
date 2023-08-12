#!/bin/bash

curl -X 'POST' 'https://morinlandon.mids255.com/predict' \
    -L -H 'Content-Type: application/json' -d \
                '{"text": ["I hate you.", "I love you."]}'