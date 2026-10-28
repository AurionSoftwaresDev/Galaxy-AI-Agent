import time
import uuid

from fastapi import FastAPI, Request

from source.routers.allRoutes import rootRouter
from source.utils.logger import server_logger

agentServer = FastAPI()

agentServer.include_router(
    router = rootRouter
)

# Logger Middleware
@agentServer.middleware(middleware_type = "http")
async def serverLogger(request: Request, next_call):

    request_id = str(object = uuid.uuid4())

    start_request_timer = time.perf_counter()

    try:

        response = await next_call(request)

    except Exception:

        server_logger.exception(
            "request_id = %s method =%s path = %s status = 500"
        )


    total_duration_of_this_request = (time.perf_counter() - start_request_timer) * 1000

    response.headers["X-Request-ID"] = request_id

    server_logger.info(
        "request_id = &s method = %s path = %s status = %s duration_ms = %.2f",
        request_id,
        request.method,
        request.url.path,
        response.status_code,
        total_duration_of_this_request
    )

    return response