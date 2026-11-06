import json

from source.config.globeConfigurations import MAP_DEFAULT_LOCATIONS
from source.gui.map.mapContextShared import (
    map_window_instance,
)


def openMap() -> str:

    try:

        map_window_instance.show()

    except Exception as unexpected_exception:

        return json.dumps(
            obj = [
                {
                    "Success": False,
                    "Default Current Locations": "None. Map Not Open",
                    "Map Open": False,
                    "Exception": str(obj = unexpected_exception)
                }
            ],
            indent = 4
        )

    return json.dumps(
        obj = [
            {
                "Success": True,
                "Default Current Locations": MAP_DEFAULT_LOCATIONS,
                "Map Open": True
            }
        ],
        indent = 4
    )