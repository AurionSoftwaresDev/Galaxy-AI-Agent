from typing import Literal

from source.config.globeConfigurations import MAPLIBRE_VERSION

JS_URL : str = f"https://unpkg.com/maplibre-gl@{MAPLIBRE_VERSION}/dist/maplibre-gl.js"
CSS_URL : str = f"https://unpkg.com/maplibre-gl@{MAPLIBRE_VERSION}/dist/maplibre-gl.css"
CARTO_STYLES : dict[str, str] = {
    "dark": "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json",
    "light": "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json",
    "voyager": "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
}

LIBERTY_STYLE : str = "https://tiles.openfreemap.org/styles/liberty"
SATELLITE_TILE_URL = (
    "https://server.arcgisonline.com/ArcGIS/rest/services/"
    "World_Imagery/MapServer/tile/{z}/{y}/{x}"
)
DEM_TILE_URL : str = "https://s3.amazonaws.com/elevation-tiles-prod/terrarium/{z}/{x}/{y}.png"
OPENFREEMAP_VECTOR_URL : str = "https://tiles.openfreemap.org/planet"