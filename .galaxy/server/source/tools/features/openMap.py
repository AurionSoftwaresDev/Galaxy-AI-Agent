import sys
from dataclasses import dataclass

from source.gui.map.mapContextShared import (
    map_application_instance,
    map_window_instance,
)
from source.utils.helper import extract_keys
from source.models.toolModels.mapModel import MapActionModel

from source.gui.map.mapFeaturesHandlersFunctions import MAP_HANDLERS_FUNCTIONS


def openMap():

    map_window_instance.show()

    sys.exit(map_application_instance.exec())

@dataclass
class tempObj:

    name: str
    age: int
    obj: object

def actionOnMap(agentMapAction : MapActionModel, *action_functions_arguments) -> str: # action_functions_arguments (Optional) Depend On Action

    agentAction : str = agentMapAction.action

    agentActionFunction = MAP_HANDLERS_FUNCTIONS[agentAction]

    try:    

        JSONResponse : str = agentActionFunction()

        return JSONResponse
    
    except TypeError: # If Action Functions Expected Arguments To Action

        return agentActionFunction(*action_functions_arguments)

myObj : tempObj = tempObj(
    "",
    0,
    {}
)

actionOnMap("write", myObj)