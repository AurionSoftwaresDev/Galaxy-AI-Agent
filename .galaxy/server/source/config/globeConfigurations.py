from pathlib import Path

APP_TITLE : str = "MAP"
MAPLIBRE_VERSION : str = "5.12.0"
CURRENT_DIR : Path = Path(__file__).resolve().parents[2]
STATIC_DIR : Path = CURRENT_DIR / "static"
JS_PATH : Path = STATIC_DIR / "maplibre-gl.js"
CSS_PATH : Path = STATIC_DIR / "maplibre-gl.css"
MODES : list[tuple[str, str]] = [
    ("globe", "◉   3D Globe"),
    ("street", "⌖   Street Map"),
    ("satellite", "◈   Satellite"),
    ("hybrid", "▧   Hybrid"),
    ("terrain", "▲   3D Terrain"),
    ("buildings", "▦   3D Buildings"),
]

MAP_APPEARANCE : list[tuple[str, str]] = [
    ("stark", "✦   Stark Blue"),
    ("dark", "◐   Dark Matter"),
    ("light", "☼   Positron Light"),
    ("voyager", "◇   Voyager"),
]