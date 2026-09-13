from pydantic import BaseModel, Field
from typing import Literal

class CreateFileModel(BaseModel):

    path : str = Field(
        description = "The directory path where the file should be created."
    )

    fileName : str = Field(
        description = "The name of the file to create."
    )

    content : str = Field(
        description = "The content that should be written into the file."
    )

    mode : Literal[
        "w",
        "a",
        "x",
    ] = Field(
        description = (
            "The file opening mode. "
            "Use 'w' to create or overwrite, "
            "'a' to append, "
            "'x' to create only if the file does not exist, "
        )
    )

