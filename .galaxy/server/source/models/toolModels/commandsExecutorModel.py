from pydantic import BaseModel, Field

class CommandExecutorInputModel(BaseModel):

    commands : list[str] = Field(
        description = "Commands to execute sequentially in the system shell."
    )