import sys, ctypes
from PyQt6.QtWidgets import QApplication, QDialog, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QGraphicsDropShadowEffect
from PyQt6.QtCore import Qt, QPoint
from PyQt6.QtGui import QColor, QFont, QPainter, QRadialGradient, QBrush, QPen, QIcon

myappid = "Aurion.GalaxyAIAgent.Backend.Diloag.Version1.0"

ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)

class NeonPremiumDialog(QDialog):
    def __init__(self, title_text="Window", error_text="An unexpected system error occurred."):
        super().__init__()
        
        # 1. Setup Window Flags for a Clean, Frameless Borderless Window
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint | Qt.WindowType.Dialog)
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        self.setFixedSize(490, 270)
        self.setWindowIcon(QIcon("source/assets/app_icon.png"))
        
        self.title_text = title_text
        self.error_text = error_text
        
        # Variables to track window dragging
        self.drag_position = QPoint()

        # 2. Main Layout Configuration
        main_layout = QVBoxLayout()
        main_layout.setContentsMargins(15, 15, 15, 15)
        self.setLayout(main_layout)

        # 3. Custom Glassmorphic Container Box
        self.container = QLabel()
        self.container.setObjectName("ContainerBox")
        self.container.setStyleSheet("""
            QLabel#ContainerBox {
                background-color: rgba(20, 10, 35, 0.85);
                border: 2px solid qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #bc13fe, stop:1 #7a04eb);
                border-radius: 16px;
            }
        """)
        
        # Inner layout for elements inside the premium box
        container_layout = QVBoxLayout(self.container)
        container_layout.setContentsMargins(20, 15, 20, 20)
        
        # 4. Custom Title Bar Layout (Since window is frameless)
        title_layout = QHBoxLayout()
        
        title_label = QLabel(self.title_text)
        title_label.setStyleSheet("color: #e0d5f5; font-size: 13px; font-weight: bold; letter-spacing: 1px;")
        
        close_btn = QPushButton("✕")
        close_btn.setFixedSize(24, 24)
        close_btn.setCursor(Qt.CursorShape.PointingHandCursor)
        close_btn.setStyleSheet("""
            QPushButton {
                background: transparent;
                color: #8c7ae6;
                border: none;
                font-size: 14px;
                font-weight: bold;
            }
            QPushButton:hover {
                color: #ff007f;
            }
        """)
        close_btn.clicked.connect(self.close)
        
        title_layout.addWidget(title_label)
        title_layout.addStretch()
        title_layout.addWidget(close_btn)
        container_layout.addLayout(title_layout)
        
        # Spacer
        container_layout.addSpacing(15)

        # 5. Content Layout (Error Message)
        content_layout = QHBoxLayout()
        
        # Glowing Neon Warning Icon
        icon_label = QLabel("⚠️")
        icon_label.setFixedSize(45, 45)
        icon_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        icon_label.setStyleSheet("""
            QLabel {
                font-size: 28px;
                background-color: rgba(188, 19, 254, 0.15);
                border: 1px solid #bc13fe;
                border-radius: 22px;
            }
        """)
        
        # Error Description
        msg_label = QLabel(self.error_text)
        msg_label.setWordWrap(True)
        msg_label.setStyleSheet("color: #f1ecfb; font-size: 14px; line-height: 140%;")
        
        content_layout.addWidget(icon_label)
        content_layout.addSpacing(15)
        content_layout.addWidget(msg_label, 1)
        container_layout.addLayout(content_layout)
        
        # Spacer
        container_layout.addSpacing(20)

        # 6. Premium Action Button
        btn_layout = QHBoxLayout()
        btn_layout.addStretch()
        
        ok_btn = QPushButton("Dismiss")
        ok_btn.setFixedSize(100, 34)
        ok_btn.setCursor(Qt.CursorShape.PointingHandCursor)
        ok_btn.setStyleSheet("""
            QPushButton {
                background-color: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #bc13fe, stop:1 #9d00ff);
                color: white;
                border: none;
                border-radius: 8px;
                font-weight: bold;
                font-size: 13px;
            }
            QPushButton:hover {
                background-color: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #d64eff, stop:1 #bc13fe);
            }
            QPushButton:pressed {
                background-color: #7a04eb;
            }
        """)
        ok_btn.clicked.connect(self.accept)
        
        # Neon Drop Shadow for the button
        shadow = QGraphicsDropShadowEffect()
        shadow.setBlurRadius(15)
        shadow.setColor(QColor(188, 19, 254, 180))
        shadow.setOffset(0, 0)
        ok_btn.setGraphicsEffect(shadow)
        
        btn_layout.addWidget(ok_btn)
        container_layout.addLayout(btn_layout)

        main_layout.addWidget(self.container)

    # 7. Paint Event to Draw Isolated Non-Overlapping Neon Orbs in Background
       # 7. Paint Event to Draw Isolated Non-Overlapping Neon Orbs in Background
    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)
        
        # Draw Orb 1 (Top Left Ambient Glow) - Using raw float values to avoid type mismatch
        gradient1 = QRadialGradient(50.0, 40.0, 90.0)
        gradient1.setColorAt(0.0, QColor(188, 19, 254, 45))  # Neon Purple
        gradient1.setColorAt(1.0, QColor(188, 19, 254, 0))   # Fades completely out
        painter.setBrush(QBrush(gradient1))
        painter.setPen(QPen(Qt.PenStyle.NoPen))
        
        # Fixed point drawing type
        painter.drawEllipse(50, 40, 90, 90)
        
        # Draw Orb 2 (Bottom Right Ambient Glow - Non-overlapping coordinates)
        gradient2 = QRadialGradient(400.0, 180.0, 100.0)
        gradient2.setColorAt(0.0, QColor(0, 240, 255, 30))   # Cyan/Neon Accent Blue
        gradient2.setColorAt(1.0, QColor(0, 240, 255, 0))    # Fades completely out
        painter.setBrush(QBrush(gradient2))
        
        # Fixed point drawing type
        painter.drawEllipse(400, 180, 100, 100)


    # 8. Enable Window Dragging Mechanisms (Since default OS frame is removed)
    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            self.drag_position = event.globalPosition().toPoint() - self.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event):
        if event.buttons() == Qt.MouseButton.LeftButton:
            self.move(event.globalPosition().toPoint() - self.drag_position)
            event.accept()