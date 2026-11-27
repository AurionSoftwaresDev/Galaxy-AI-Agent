from PyQt6.QtCore import (
    QEasingCurve,
    QEvent,
    QObject,
    QPropertyAnimation,
    QRectF,
    Qt,
    QTimer,
    pyqtProperty,
    pyqtSignal,
)
from PyQt6.QtGui import QColor, QMouseEvent, QPainter, QPaintEvent, QPen
from PyQt6.QtWidgets import QFrame, QHBoxLayout, QLabel, QLineEdit
from source.utils.browserUtils import makeIcon, mix

from source.config.browerConfigurations import ACCENT


class UrlPill(QFrame):

    """Display a rounded URL bar with a smooth focus animation."""
    escaped : pyqtSignal = pyqtSignal()

    def __init__(self) -> None:

        super().__init__()

        self._focusValue: float = 0.0
        
        self.setFixedHeight(36)
        self.setCursor(Qt.CursorShape.IBeamCursor)

        urlBarLayout : QHBoxLayout = QHBoxLayout(self)

        urlBarLayout.setContentsMargins(13, 0, 14, 0)
        urlBarLayout.setSpacing(8)

        self.icon : QLabel = QLabel()
        self.edit : QLineEdit = QLineEdit()
        self._animation = QPropertyAnimation(self, b"focusAmount", self)

        self.icon.setFixedSize(16, 16)
        self.edit.setPlaceholderText("Search Google or type a URL")

        self.edit.setStyleSheet(
            "QLineEdit{background:transparent;border:none;font-size:14px;color:#202124;"
            "selection-background-color:#c2dbff;selection-color:#202124;}"
        )

        self.edit.installEventFilter(self)

        urlBarLayout.addWidget(self.icon)

        urlBarLayout.addWidget(self.edit, 1)
        
        self._animation.setDuration(180)
        self._animation.setEasingCurve(QEasingCurve.Type.OutCubic)

        self.setState("none")

    def _getFocusAmount(self) -> float:
        
        return self._focusValue

    def _setFocusAmount(self, focusValue : float) -> None:

        self._focusValue = focusValue

        self.update()

    focusAmount = pyqtProperty(float, _getFocusAmount, _setFocusAmount)

    def setState(self, securityState : str) -> None:

        iconName : str = {"secure": "lock", "insecure": "info"}.get(securityState, "search")

        self.icon.setPixmap(makeIcon(iconName).pixmap(16, 16))

        self.icon.setToolTip(
            {"secure": "Connection is secure", "insecure": "Not secure"}.get(securityState, "")
        )

    def _animate(self, targetValue : float) -> None:

        self._animation.stop()
        self._animation.setStartValue(self._focusValue)
        self._animation.setEndValue(targetValue)
        self._animation.start()

    def eventFilter(self, watchedObject : QObject, event : QEvent) -> bool:

        if watchedObject is self.edit:

            eventType : QEvent.Type = event.type()

            if eventType == QEvent.Type.FocusIn:

                self._animate(1.0)

                QTimer.singleShot(0, self.edit.selectAll)

            elif eventType == QEvent.Type.FocusOut:

                self._animate(0.0)
                
                self.edit.deselect()

            elif eventType == QEvent.Type.KeyPress and event.key() == Qt.Key.Key_Escape:

                self.escaped.emit()

                return True

        return super().eventFilter(watchedObject, event)

    def mousePressEvent(self, event: QMouseEvent) -> None:
        
        self.edit.setFocus()

    def paintEvent(self, event : QPaintEvent) -> None:

        painter: QPainter = QPainter(self)

        painter.setRenderHint(QPainter.RenderHint.Antialiasing)

        border : QColor = QColor(ACCENT)
        urlBarRect : QRectF = QRectF(self.rect()).adjusted(1, 1, -1, -1)

        border.setAlphaF(self._focusValue)

        painter.setBrush(mix(QColor("#f1f3f4"), QColor("#ffffff"), self._focusValue))
        painter.setPen(QPen(border, 2))
        painter.drawRoundedRect(urlBarRect, urlBarRect.height() / 2, urlBarRect.height() / 2)
