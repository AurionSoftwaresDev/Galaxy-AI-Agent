import sys

from PyQt6.QtCore import QCoreApplication
from PyQt6.QtWidgets import QApplication

from source.gui.map.map import DesktopGlobeWindow, map_ready
from source.gui.map.mapFeaturesFunctions import MapFunctions

js_ready, css_ready = map_ready()

map_application_instance : QCoreApplication = QApplication.instance() or QApplication(sys.argv)

map_window_instance : DesktopGlobeWindow = DesktopGlobeWindow(
    libraries_ready = js_ready and css_ready
)

mapFunctions : MapFunctions = MapFunctions(map_window_instance)