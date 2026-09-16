from pydantic import BaseModel, Field

class DeleteFileModel(BaseModel):

    filePath : str = Field(
        description=(
            "The directory path containing the file that needs to be deleted."
        )
    )

    fileName : str = Field(
        description=(
            "The name of the file that needs to be deleted."
        )
    )