from langchain.core.StructuredTool import StructuredTool

from source.gui.map.mapContextShared import mapFunctions
from source.models.toolModels.map.addCoordinateMarkerModel import (
    AddCoordinateMarkerModel,
)
from source.models.toolModels.map.calculateCoordinateDistanceModel import (
    CalculateCoordinateDistanceModel,
)
from source.models.toolModels.map.flyToLocationModel import FlyToLocationModel
from source.tools.features.openMap import openMap

openMapTool : StructuredTool = StructuredTool.from_function(
    name = "open_map",
    func = openMap,
    description = """
        Opens the interactive geographical map interface powered by MapLibre GL JS.
        
        Use this tool when the user explicitly requests to open, display, or
        explore the interactive map.
        
        The map provides the following visualization modes:
        - Globe: 3D globe visualization.
        - Street: Standard street map.
        - Satellite: Satellite imagery.
        - Hybrid: Satellite imagery with geographical details.
        - Terrain: 3D terrain visualization.
        - Buildings: 3D building visualization.
        
        Available map appearance themes:
        - Stark Blue
        - Dark Matter
        - Positron Light
        - Voyager
        
        Users can switch between supported map modes and appearance themes
        directly through the map interface.
        
        The map also supports geographical navigation, multiple location
        markers, and coordinate-based distance calculations.
        
        Do not call this tool if the map is already open and the user only
        wants to perform an operation on the existing map.
    """
)

flyToLocationTool : StructuredTool = StructuredTool.from_function(
    name = "fly_to_location_on_map",
    func = mapFunctions.fly_to_coordinate_location,
    args_schema = FlyToLocationModel,
    description = """
        Navigates the interactive map camera to a specified geographical
        location using latitude and longitude coordinates.
        
        Use this tool when the user wants to:
        - Navigate to a specific geographical location.
        - Focus the map on a particular coordinate.
        - Zoom into or explore a specific geographical area.
        - Change the current map camera position.
        
        Parameters:
        - latitude: Latitude of the target location in decimal degrees.
          Valid range: -90 to 90.
        - longitude: Longitude of the target location in decimal degrees.
          Valid range: -180 to 180.
        - zoom: Desired map zoom level. Must follow the map application's
          supported zoom configuration.
        
        This operation updates the map camera position and zoom level.
        It does not add a location marker.
        
        Do not call this tool when the user only wants to add a marker
        or calculate the distance between two locations.
    """
)

addMarkerOnCoordinateTool : StructuredTool = StructuredTool.from_function(
    name = "add_marker_on_coordinate_on_map",
    func =  mapFunctions.add_coordinate_markers,
    args_schema = AddCoordinateMarkerModel,
    description = """
        Adds a geographical location marker to the interactive map using
        the specified latitude and longitude coordinates.
        
        Use this tool when the user wants to:
        - Pin or mark a geographical location.
        - Highlight a specific coordinate on the map.
        - Add a visual reference point.
        - Mark multiple geographical locations on the map.
        
        Parameters:
        - latitude: Latitude of the location in decimal degrees.
          Valid range: -90 to 90.
        - longitude: Longitude of the location in decimal degrees.
          Valid range: -180 to 180.
        
        The map supports multiple location markers, allowing users to
        visualize several geographical points simultaneously.
        
        Adding a marker is independent of map camera navigation.
        
        Do not call this tool when the user only wants to navigate
        the map without adding a marker.
    """
)

calculateCoordinateDistanceTool : StructuredTool = StructuredTool.from_function(
    name = "calculate_coordinate_distance_on_map",
    func = mapFunctions.calculate_coordinate_distance,
    args_schema = CalculateCoordinateDistanceModel,
    description = """
        Calculates the geographical distance between two locations using
        their latitude and longitude coordinates.
        
        Use this tool when the user wants to:
        - Calculate the distance between two geographical locations.
        - Find the geographical separation between two coordinate points.
        - Compare the distance between two locations.
        
        Parameters:
        - latitude_a: Latitude of the first location in decimal degrees.
          Valid range: -90 to 90.
        - longitude_a: Longitude of the first location in decimal degrees.
          Valid range: -180 to 180.
        - latitude_b: Latitude of the second location in decimal degrees.
          Valid range: -90 to 90.
        - longitude_b: Longitude of the second location in decimal degrees.
          Valid range: -180 to 180.
        
        The calculation returns the geographical distance in kilometers.
        
        The calculation is coordinate-based and does not represent
        road distance, driving distance, or travel time.
        
        Use this tool when both geographical coordinate pairs are available.
        Do not assume coordinates if they have not been provided or resolved.
    """
)