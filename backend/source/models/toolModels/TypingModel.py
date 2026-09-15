from pydantic import BaseModel, Field
from typing import Optional

class TypingModel(BaseModel):
    text : str = Field(
        ..., 
        description = "The exact text string that needs to be typed into the active window or input field. Do not modify or translate."
    )
    wait_time : Optional[float] = Field(
        default=3.0,
        description = "The initial delay in seconds to wait before typing starts. This allows the user to switch windows. Default is 3.0 seconds. Increase this if the user asks for a longer wait."
    )
