import os
import urllib.error
import urllib.request
from pathlib import Path

from PyQt6.QtCore import QUrl

from source.config.globeConfigurations import (
    CSS_PATH,
    JS_PATH,
    STATIC_DIR,
)
from source.config.Urls import (
    CARTO_STYLES,
    DEM_TILE_URL,
    LIBERTY_STYLE,
    OPENFREEMAP_VECTOR_URL,
    SATELLITE_TILE_URL,
)
from source.constants.gui.globe.globeHTMLTemplate import HTML_GLOBE_TEMPLATE
from source.utils.logger import logger


def is_html_content(content : bytes) -> bool:

    sample = content.lstrip()[:1024].lower()

    return not sample or sample.startswith(b"<") or b"<!doctype html" in sample

def verify_and_download(file_path : Path, url : str, name : str) -> bool:

    STATIC_DIR.mkdir(parents = True, exist_ok = True)

    if file_path.is_file():

        try:

            sample = file_path.read_bytes()[:1024]
            
            if not is_html_content(content = sample):

                logger.info(f"[OK] { name } exists: { file_path }")

                return True

            logger.info(f"[WARNING] { name } contains HTML; replacing it.")

        except OSError as error:

            print(f"[ERROR] Cannot inspect { name } : { error }")

            return False

    temporary_path = file_path.with_suffix(suffix = file_path.suffix + ".download")

    try:

        request = urllib.request.Request(
            url = url, 
            headers = {
                "User-Agent": "StarkGlobe/1.0"
            }
        )
        
        logger.debug(f"[INFO] Downloading { name } from { url }")

        with urllib.request.urlopen(url = request, timeout = 35) as response:

            content = response.read()

            content_type = response.headers.get("Content-Type", "").lower()

        if "text/html" in content_type or is_html_content(content):

            logger.exception(f"[ERROR] The server returned HTML instead of { name }.")

            return False

        if len(content) < 10_000:
            logger.exception(
                f"[ERROR] Downloaded {name} is unexpectedly small "
                f"({len(content)} bytes)."
            )

            return False

        temporary_path.write_bytes(data = content)

        os.replace(src = temporary_path, dst = file_path)

        logger.info(f"[OK] Downloaded { name } ({ len(content):,} bytes).")

        return True

    except (OSError, urllib.error.URLError, TimeoutError) as error:

        logger.exception(f"[ERROR] Download failed for { name } : { error}")

        return False
    
    finally:

        try:

            temporary_path.unlink(missing_ok = True)

        except OSError:

            pass

def create_map_html() -> str:

    js_url : str = QUrl.fromLocalFile(str(object = JS_PATH)).toString()

    css_url : str = QUrl.fromLocalFile(str(object = CSS_PATH)).toString()

    template = HTML_GLOBE_TEMPLATE
   
    replacements : dict = {
        "__CSS_URL__": css_url,
        "__JS_URL__": js_url,
        "__STYLES__": __import__("json").dumps(CARTO_STYLES),
        "__LIBERTY_STYLE__": __import__("json").dumps(LIBERTY_STYLE),
        "__SATELLITE_URL__": __import__("json").dumps(SATELLITE_TILE_URL),
        "__DEM_URL__": __import__("json").dumps(DEM_TILE_URL),
        "__VECTOR_URL__": __import__("json").dumps(OPENFREEMAP_VECTOR_URL),
    }
    
    for placeholder, value in replacements.items():

        template = template.replace(placeholder, value)
        
    return template