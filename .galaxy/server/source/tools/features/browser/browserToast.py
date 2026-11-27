from PyQt6.QtCore import QPropertyAnimation, QRect, Qt, QTimer
from PyQt6.QtWidgets import QLabel, QWidget


class Toast(QLabel):

    """Display small fade-in and fade-out notifications."""
    def __init__(self, owner : QWidget) -> None:

        super().__init__(owner)

        self._owner : QWidget = owner
        self._isHiding : bool = False

        self.setWindowFlags(Qt.WindowType.ToolTip | Qt.WindowType.FramelessWindowHint)

        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        self.setAttribute(Qt.WidgetAttribute.WA_ShowWithoutActivating)
        self.setAttribute(Qt.WidgetAttribute.WA_TransparentForMouseEvents)

        self.setStyleSheet(
            "background:#202124;color:#fff;border-radius:12px;"
            "padding:10px 18px;font-size:13px;"
        )

        self._animation : QPropertyAnimation = QPropertyAnimation(self, b"windowOpacity", self)
        self._animation.setDuration(180)
        self._animation.finished.connect(self._done)

        self._hideTimer : QTimer = QTimer(self)
        self._hideTimer.setSingleShot(True)
        self._hideTimer.timeout.connect(self._fadeOut)

    def showMessage(self, text : str, durationMilliseconds : int = 2200) -> None:

        self._hideTimer.stop()

        self._animation.stop()

        self._isHiding = False

        self.setText(text)
        self.adjustSize()

        ownerGeometry : QRect = self._owner.geometry()
        toastX : int = ownerGeometry.x() + (ownerGeometry.width() - self.width()) // 2
        toastY : int = ownerGeometry.y() + ownerGeometry.height() - self.height() - 40

        self.move(toastX, toastY)

        startOpacity : float = self.windowOpacity() if self.isVisible() else 0.0

        self.setWindowOpacity(startOpacity)
        self.show()
        self.raise_()

        self._animation.setStartValue(startOpacity)
        self._animation.setEndValue(1.0)
        self._animation.start()

        self._hideTimer.start(durationMilliseconds)

    def _fadeOut(self) -> None:

        self._isHiding = True

        self._animation.stop()
        self._animation.setStartValue(self.windowOpacity())
        self._animation.setEndValue(0.0)
        self._animation.start()

    def _done(self) -> None:

        if self._isHiding:

            self._isHiding = False

            self.hide()

