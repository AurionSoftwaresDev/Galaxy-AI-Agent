from pydantic import BaseModel, Field


class CreateFolderModel(BaseModel):

    path: str = Field(
        description="The parent directory where the folder should be created."
    )

    folderName: str = Field(
        description="The name of the folder to create."
    )

    parents: bool = Field(
        default=True,
        description=(
            "Whether to automatically create missing parent directories. "
            "Set to True when the required parent directories may not exist."
        )
    )