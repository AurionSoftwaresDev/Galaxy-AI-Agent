from pydantic import BaseModel, Field


class OpenBrowserModel(BaseModel):

    url : str | None = Field(description = "Website URL(Optional)")    