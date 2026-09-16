from pydantic import BaseModel, Field

class ReadFileModel(BaseModel):

    filePath: str = Field(
        description=(
            "The directory path containing the file that needs to be read."
        )
    )

    fileName: str = Field(
        description=(
            "The name of the file to read. "
            "Nested file paths are also supported."
        )
    )
