from fastapi import (
    Response,
    status
)

def agentHealth(response : Response):
    
    response.status_code = status.HTTP_200_OK

    return {
        "Status": 200,
        "Message": "AI Agent Server Health Is Good."
    }

    