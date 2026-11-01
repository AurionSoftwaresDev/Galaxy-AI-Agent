import sys

from PyQt6.QtCore import QCoreApplication
from PyQt6.QtWidgets import QApplication

from source.gui.map.map import DesktopGlobeWindow, map_ready

js_ready, css_ready = map_ready()

map_application_instance : QCoreApplication = QApplication.instance() or QApplication(sys.argv)

map_window_instance : DesktopGlobeWindow = DesktopGlobeWindow(
    libraries_ready = js_ready and css_ready
)
