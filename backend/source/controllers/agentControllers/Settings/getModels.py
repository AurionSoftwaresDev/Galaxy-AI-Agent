from fastapi import Response, status
from source.provider.models import models

def getAvaliableLLMModels(response : Response) -> dict[str, list[str]]:

    response.status_code = status.HTTP_200_OK

    return {
        "Avaliable Models" : models
    }