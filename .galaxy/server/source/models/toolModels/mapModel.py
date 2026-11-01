
from pydantic import BaseModel, Field, field_validator

from source.gui.map.mapFeaturesHandlersFunctions import __map_action_keys__


class MapActionModel(BaseModel):

    action : str = Field(
        title = "Map Action Keys",
        description = "This Keys Provide Features For Map Manipluate",
        json_schema_extra = {
            "Actions": list(__map_action_keys__)
        }
    )

    @field_validator("action")

    @classmethod
    def validate_action(cls, value : str):

        if value not in __map_action_keys__:

            raise ValueError("Invalid Action Key For Map!")

        return value