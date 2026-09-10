from typing import Literal

from pydantic import BaseModel, Field

class OpenBrowserModel(BaseModel):

    url : str = Field(description = "Website URL")   