from pydantic import BaseModel, Field

class DeleteFolderModel(BaseModel):

    folderPath : str = Field(
        description=(
            "The parent directory containing the folder that needs to be deleted."
        )
    )

    folderName : str = Field(
        description=(
            "The name of the folder that needs to be deleted."
        )
    )