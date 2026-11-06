from pydantic import BaseModel, Field


class CalculateCoordinateDistanceModel(BaseModel):

    latitude_a : float = Field(ge = -90, le = 90)
    latitude_b : float = Field(ge = -90, le = 90)
    longitude_a : float = Field(ge = -180, le = 180)
    longitude_b : float = Field(ge = -180, le = 180)