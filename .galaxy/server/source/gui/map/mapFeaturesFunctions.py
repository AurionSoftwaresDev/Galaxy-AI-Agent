import json

from source.gui.map.map import DesktopGlobeWindow
from source.models.toolModels.map.addCoordinateMarkerModel import (
    AddCoordinateMarkerModel,
)
from source.models.toolModels.map.calculateCoordinateDistanceModel import (
    CalculateCoordinateDistanceModel,
)
from source.models.toolModels.map.flyToLocationModel import FlyToLocationModel


class MapFunctions:

    def __init__(self, map_instance : DesktopGlobeWindow):

        self.map_instance = map_instance

    def calculate_coordinate_distance(self, meta_data : CalculateCoordinateDistanceModel) -> str:

        latitude_a : float = meta_data.latitude_a
        latitude_b : float = meta_data.latitude_b
        longitude_a : float = meta_data.longitude_a
        longitude_b : float = meta_data.longitude_b

        distance_string : str = self.map_instance.calculate_coordinate_distance(
            mode = "agent",
            meta_data = {
                "latitude_a" : latitude_a,
                "latitude_b": latitude_b,
                "longitude_a": longitude_a,
                "longitude_b": longitude_b
            }
        )

        if distance_string:

            return json.dumps(
                obj = [
                    {
                        "Given Details": {
                            "Latitude A": latitude_a,
                            "Latitude B": latitude_b,
                            "Longitude A": longitude_a,
                            "Longitude B": longitude_b,
                        },
                        "Calculated Output Distance String": distance_string
                    }
                ],
                indent = 4
            )

        return json.dumps(
            obj = [
                {
                    "Error": "Failed To Calculate Coordinate Distance. Invalid Coordinate",
                }
            ], indent = 4
        )

    def add_coordinate_markers(self, meta_data : AddCoordinateMarkerModel) -> str:

        latitude : float = meta_data.latitude
        longitude : float = meta_data.longitude

        marker_data = self.map_instance.add_coordinate_marker(
            mode = "agent",
            meta_data = {
                "latitude" : latitude,
                "longitude" : longitude
            }
        )

        if marker_data:

            return json.dumps(
                obj = [
                    {
                        "Success": True,
                        "Latitude": latitude,
                        "Longitude": longitude,
                        "Add Marker Tool Data": marker_data,
                    }
                ]
            )

        return json.dumps(
            obj = [
                {
                    "Success": False,
                    "Latitude": latitude,
                    "Longitude": longitude,
                    "Add Marker Tool Data": "Invalid Coordinate, Failed To Mark Marker"
                }
            ],
            indent = 4
        )

    def fly_to_coordinate_location(self, meta_data : FlyToLocationModel) -> str:

        longitude = meta_data.longitude
        latitude = meta_data.latitude
        zoom = meta_data.zoom

        fly_location_data = self.fly_to_location(
            mode = "agent",
            meta_data = {
                "latitude" : latitude,
                "longitude" : longitude,
                "zoom" : zoom
            }
        )

        if fly_location_data:

            return json.dumps(
                obj = [
                    {
                        "Success": True,
                        "Latitude": latitude,
                        "Longitude": longitude,
                        "Zoom": zoom,
                        "Fly Data": fly_location_data
                    }
                ], indent = 4
            )

        return json.dumps(
            obj = [
                {
                    "Success": False,
                    "Latitude": latitude,
                    "Longitude": longitude,
                    "Zoom": zoom,
                    "Fly Data": "Invalid Location Or Latitude/Longitude, Check Your Data."
                }
            ], indent = 4
        )