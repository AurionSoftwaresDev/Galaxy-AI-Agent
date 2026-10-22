from source.constants.gui.globe.globeColors import COLORS

GLOBE_STYLE_SHEET = f"""
   
    QMainWindow, QWidget {{
        background: {COLORS['background']};
        color: {COLORS['text']};
        font-family: Segoe UI, Arial;
        font-size: 10pt;
    }}
    QLabel#muted {{ color: {COLORS['muted']}; font-size: 9pt; }}
    QLabel#section {{
        color: {COLORS['muted']}; font-size: 8pt; font-weight: bold;
        padding-top: 12px; padding-bottom: 4px;
    }}
    QPushButton {{
        background: {COLORS['sidebar']}; color: {COLORS['text']};
        border: 1px solid {COLORS['border']}; border-radius: 7px;
        padding: 10px; text-align: left;
    }}
    QPushButton:hover {{
        background: {COLORS['panel']}; border-color: {COLORS['blue']};
    }}
    QPushButton#primary {{
        background: {COLORS['selected']};
        border: 1px solid {COLORS['blue']}; color: white; font-weight: bold;
    }}
    QLineEdit {{
        background: {COLORS['sidebar']}; color: {COLORS['text']};
        border: 1px solid {COLORS['border']}; border-radius: 6px; padding: 9px;
    }}
    QFrame#separator {{
        background: {COLORS['border']}; max-height: 1px; min-height: 1px; border: none;
    }}
    QScrollArea {{ border: none; background: {COLORS['sidebar']}; }}
    
"""