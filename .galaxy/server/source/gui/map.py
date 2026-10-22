from __future__ import annotations

import os
import sys

from PyQt6.QtCore import QUrl, Qt, QTimer
from PyQt6.QtWidgets import (
    QApplication,
    QFrame,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QMainWindow,
    QMessageBox,
    QPushButton,
    QScrollArea,
    QVBoxLayout,
    QWidget,
)
from PyQt6.QtWebEngineWidgets import QWebEngineView

from source.utils.globeUtils import verify_and_download, create_map_html
from source.constants.gui.globe.globeColors import COLORS
from source.constants.gui.globe.globeStyleSheet import GLOBE_STYLE_SHEET
from source.config.Urls import (
    JS_URL,
    CSS_URL,
)
from source.config.globeConfigurations import (
    APP_TITLE,
    CSS_PATH,
    JS_PATH,
    CURRENT_DIR,
    MODES,
    MAP_APPEARANCE
)

class DesktopGlobeWindow(QMainWindow):

    def __init__(self, libraries_ready: bool):

        super().__init__()

        self.setWindowTitle(APP_TITLE)
        self.resize(1400, 850)
        self.setMinimumSize(760, 520)
        self.setStyleSheet(GLOBE_STYLE_SHEET)

        self.mode_buttons = {}

        # FEATURES PARTs
        self.browser : QWebEngineView = QWebEngineView()
        self.btn_2d : QPushButton = QPushButton(text = "2D View")
        self.btn_3d : QPushButton = QPushButton(text = "3D View")
        self.distance_result : QLabel = QLabel(text = "Distance: —")
        self.lng_input : QLineEdit = QLineEdit("78.9629")
        self.lat_input : QLineEdit = QLineEdit("20.5937")
        self.zoom_input : QLineEdit = QLineEdit("5")
        self.marker_lng_input : QLineEdit = QLineEdit("78.9629")
        self.marker_lat_input : QLineEdit = QLineEdit("20.5937")

        # GUI PARTs
        title : QLabel = QLabel(text = "✦ MAPS/GLOBE")
        subtitle : QLabel = QLabel(text = "MAP/GLOBE CONTROL PANEL")
        footer : QLabel = QLabel(text ="STARK BLUE  •  MAPLIBRE GL")
        main : QWidget = QWidget()
        sidebar : QWidget = QWidget()
        root :  QHBoxLayout = QHBoxLayout(main)
        side : QVBoxLayout = QVBoxLayout(sidebar)
        camera_row : QHBoxLayout = QHBoxLayout()
        scroll : QScrollArea = QScrollArea()
        distance_button : QPushButton = QPushButton(text = "Calculate straight-line distance")
        mark_button : QPushButton = QPushButton(text = "＋  Add separate markers")
        clear_button : QPushButton = QPushButton(text = "✕  Clear all markers")
        add_marker_button : QPushButton = QPushButton(text = "＋  Add coordinate marker")
        fly_button : QPushButton = QPushButton(text = "➤   Fly to Location")
        line_button : QPushButton = QPushButton(text = "╱  Draw connected line (2+ points)")
        finish_line_button : QPushButton = QPushButton(text = "✓  Finish connected line")
        measure_button : QPushButton = QPushButton(text = "↔  Measure distance (2 points)")

        self.setCentralWidget(main)
        sidebar.setMinimumWidth(245)
        side.setSpacing(7)
        root.setSpacing(0)
        root.setContentsMargins(
            0, 
            0, 
            0, 
            0
        )
        side.setContentsMargins(
            15, 
            18, 
            15,
            16
        )

        title.setStyleSheet(
            f"font-size: 18pt; font-weight: bold; color: {COLORS['blue']}"
        )

        subtitle.setObjectName("muted")

        side.addWidget(title)
        side.addWidget(subtitle)
        side.addWidget(self.separator())

        self.section(layout = side, text = "MAP MODES")

        for mode, label in MODES:
            
            button : QPushButton = QPushButton(text = label)
            button.setMinimumHeight(39)
            button.clicked.connect(
                slot = lambda checked = False, value = mode: self.change_mode(mode = value)
            )

            side.addWidget(button)

            self.mode_buttons[mode] = button

        self.select_mode_button(selected = "globe")

        side.addWidget(self.separator())
        
        self.section(layout = side, text = "APPEARANCE")

        for theme, label in MAP_APPEARANCE:

            button = QPushButton(text = label)

            button.clicked.connect(
                slot = lambda checked = False, value = theme: self.change_theme(theme = value)
            )

            side.addWidget(button)

        side.addWidget(self.separator())

        self.section(layout = side, text = "CAMERA")
        
        self.btn_2d.clicked.connect(slot = lambda : self.set_camera(mode = "2d"))
        self.btn_3d.clicked.connect(slot = lambda : self.set_camera(mode = "3d"))

        camera_row.addWidget(self.btn_2d)
        camera_row.addWidget(self.btn_3d)

        side.addLayout(camera_row)

        side.addWidget(self.separator())
        self.section(layout = side, text = "FLY TO LOCATION")

        self.lng_input.setPlaceholderText("Longitude")
        side.addWidget(self.lng_input)

        self.lat_input.setPlaceholderText("Latitude")
        side.addWidget(self.lat_input)
        
        self.zoom_input.setPlaceholderText("Zoom (0–20)")
        side.addWidget(self.zoom_input)

        fly_button.setObjectName("primary")
        fly_button.clicked.connect(slot = self.fly_to_location)

        side.addWidget(fly_button)

        side.addWidget(self.separator())
        self.section(
            layout = side, 
            text = "MARKERS, CONNECTED LINE & DISTANCE"
        )
        mark_button.clicked.connect(
            slot = lambda : self.run_map_javascript("setClickMode", "mark")
        )

        side.addWidget(mark_button)
        line_button.setObjectName("primary")
        line_button.clicked.connect(
            slot = lambda : self.run_map_javascript("setClickMode", "line")
        )

        side.addWidget(line_button)
        finish_line_button.clicked.connect(
            slot = lambda : self.run_map_javascript(function_name = "finishLine")
        )

        side.addWidget(finish_line_button)
        measure_button.clicked.connect(
            slot = lambda : self.run_map_javascript("setClickMode", "measure")
        )

        side.addWidget(measure_button)
        line_help = QLabel(
            text = "Connected lines follow the active map projection: globe on 3D Globe, flat on 2D maps, and ground-draped on terrain/building maps. Distance is summed between each pair of points."
        )

        line_help.setWordWrap(True)
        line_help.setObjectName("muted")
        side.addWidget(line_help)

        self.section(layout = side, text = "ADD MARKER BY COORDINATES")

        self.marker_lng_input.setPlaceholderText("Marker longitude")
        side.addWidget(self.marker_lng_input)

        self.marker_lat_input.setPlaceholderText("Marker latitude")
        side.addWidget(self.marker_lat_input)

        add_marker_button.clicked.connect(slot = self.add_coordinate_marker)

        side.addWidget(add_marker_button)

        self.section(layout = side, text = "DISTANCE BETWEEN COORDINATES")

        self.distance_inputs = []

        for placeholder, value in [
            ("Point A longitude", "78.9629"),
            ("Point A latitude", "20.5937"),
            ("Point B longitude", "77.5946"),
            ("Point B latitude", "12.9716"),
        ]:
            field = QLineEdit(value)
            field.setPlaceholderText(placeholder)
            side.addWidget(field)
            self.distance_inputs.append(field)

        distance_button.setObjectName("primary")
        distance_button.clicked.connect(slot = self.calculate_coordinate_distance)

        side.addWidget(distance_button)

        self.distance_result.setWordWrap(True)
        self.distance_result.setObjectName("muted")

        side.addWidget(self.distance_result)

        clear_button.clicked.connect(slot = self.clear_markers)

        side.addWidget(clear_button)

        side.addStretch()

        footer.setObjectName("muted")
        
        side.addWidget(footer)

        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QFrame.Shape.NoFrame)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
        scroll.setVerticalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAsNeeded)
        scroll.setFixedWidth(290)
        scroll.setWidget(sidebar)
        root.addWidget(scroll)
        
        settings = self.browser.settings()

        settings.setAttribute(
            settings.WebAttribute.LocalContentCanAccessRemoteUrls, 
            True
        )

        settings.setAttribute(
            settings.WebAttribute.LocalContentCanAccessFileUrls,
            True
        )
        settings.setAttribute(
            settings.WebAttribute.JavascriptEnabled, 
            True
        )

        if libraries_ready:

            self.browser.setHtml(
                create_map_html(), 
                baseUrl = QUrl.fromLocalFile(
                    str(
                        object = CURRENT_DIR
                    ) + os.sep
                )
            )
        else:

            self.browser.setHtml(
                html = "<h3>MapLibre assets unavailable</h3>"
                "<p>Check your internet connection and the ./static folder.</p>"
            )
        root.addWidget(self.browser, stretch = 1)
        
        self.set_camera_button_state(mode = "3d")

    def resizeEvent(self, event):

        super().resizeEvent(event)

        QTimer.singleShot(
            0,
            lambda : self.run_map_javascript("resize")
        )

    @staticmethod
    def separator():

        frame = QFrame()

        frame.setObjectName("separator")

        frame.setFrameShape(QFrame.Shape.HLine)

        return frame

    @staticmethod
    def section(layout, text):

        label : QLabel = QLabel(text)

        label.setObjectName("section")

        layout.addWidget(label)

    def select_mode_button(self, selected):

        for mode, button in self.mode_buttons.items():

            button.setObjectName("primary" if mode == selected else "")
            button.style().unpolish(button)
            button.style().polish(button)
            button.update()

    def run_map_javascript(self, function_name, *arguments):

        import json

        args = ",".join(json.dumps(value) for value in arguments)
        code = (
            "if(window.starkGlobe && typeof window.starkGlobe."
            + function_name
            + "==='function'){window.starkGlobe."
            + function_name
            + "("
            + args
            + ");}else{console.warn('Map application is not ready yet.');}"
        )

        self.browser.page().runJavaScript(code)

    def change_mode(self, mode):

        self.select_mode_button(selected = mode)

        self.run_map_javascript("changeMode", mode)

    def change_theme(self, theme):

        self.run_map_javascript("changeTheme", theme)

    def set_camera_button_state(self, mode):

        self.btn_2d.setObjectName("primary" if mode == "2d" else "")
        
        self.btn_3d.setObjectName("primary" if mode == "3d" else "")

        for button in (self.btn_2d, self.btn_3d):
            
            button.style().unpolish(button)
            button.style().polish(button)
            button.update()

    def set_camera(self, mode):
        
        self.set_camera_button_state(mode)

        self.run_map_javascript("setCamera", mode)

    def fly_to_location(self):

        try:
            
            longitude = float(self.lng_input.text().strip())
            latitude = float(self.lat_input.text().strip())
            zoom = float(self.zoom_input.text().strip())
            
            if not -180 <= longitude <= 180:

                raise ValueError("Longitude must be between -180 and 180.")

            if not -90 <= latitude <= 90:

                raise ValueError("Latitude must be between -90 and 90.")

            if not 0 <= zoom <= 20:
                
                raise ValueError("Zoom must be between 0 and 20.")

        except ValueError as error:

            QMessageBox.warning(
                self, 
                title = "Invalid Location", 
                text = str(object = error)
            )

            return

        self.run_map_javascript("flyToLocation", longitude, latitude, zoom)

    def add_coordinate_marker(self):

        try:

            longitude : float = float(self.marker_lng_input.text().strip())

            latitude : float = float(self.marker_lat_input.text().strip())

            if not -180 <= longitude <= 180 or not -90 <= latitude <= 90:

                raise ValueError("Longitude must be −180…180 and latitude −90…90.")

        except ValueError as error:

            QMessageBox.warning(
                parent = self, 
                title = "Invalid Coordinates", 
                text = str(object = error)
            )
            
            return

        self.run_map_javascript("addMarker", longitude, latitude)
        self.run_map_javascript("flyToLocation", longitude, latitude, 8)

    def calculate_coordinate_distance(self):

        try:
            
            lng_a, lat_a, lng_b, lat_b = [
                float(field.text().strip()) for field in self.distance_inputs
            ]

            if not (-180 <= lng_a <= 180 and -180 <= lng_b <= 180):
                
                raise ValueError("Longitude must be between −180 and 180.")

            if not (-90 <= lat_a <= 90 and -90 <= lat_b <= 90):
                
                raise ValueError("Latitude must be between −90 and 90.")

        except ValueError as error:

            QMessageBox.warning(
                parent = self, 
                title = "Invalid Coordinates", 
                text = str(object = error)
            )

            return

        from math import atan2, cos, radians, sin, sqrt

        lat1, lat2 = radians(lat_a), radians(lat_b)

        dlat, dlng = radians(lat_b - lat_a), radians(lng_b - lng_a)

        h : float = sin(dlat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(dlng / 2) ** 2

        km : float = 6371.0088 * 2 * atan2(sqrt(h), sqrt(max(0.0, 1 - h)))

        self.distance_result.setText(
            f"Distance: {km:,.3f} km  ({km * 0.621371:,.3f} miles)\nStraight-line / great-circle distance"
        )

    def clear_markers(self):

        self.run_map_javascript("clearMarkers")

        self.distance_result.setText("Distance: —")


def start_map():

    app : QApplication = QApplication(sys.argv)

    js_ready : bool = verify_and_download(
        file_path = JS_PATH, 
        url = JS_URL, 
        name = "maplibre-gl.js"
    )

    css_ready : bool = verify_and_download(
        file_path = CSS_PATH, 
        url = CSS_URL, 
        name = "maplibre-gl.css"
    )

    window : DesktopGlobeWindow = DesktopGlobeWindow(
        libraries_ready = js_ready and css_ready
    )

    window.show()

    sys.exit(app.exec())