from fastapi import Response, status
from source.provider.providers import providers

def getAvaliabeProviders(response : Response) -> dict[str, list[str]]: 

    response.status_code = status.HTTP_200_OK

    return {
        "Avaliable Providers" : providers
    }