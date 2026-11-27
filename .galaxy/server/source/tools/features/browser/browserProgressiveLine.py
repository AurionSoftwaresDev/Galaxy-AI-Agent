from PyQt6.QtCore import QEasingCurve, QPropertyAnimation, QRectF, pyqtProperty
from PyQt6.QtGui import QColor, QPainter, QPaintEvent
from PyQt6.QtWidgets import QWidget

from source.config.browerConfigurations import ACCENT


class ProgressLine(QWidget):

    """Display a smoothly animated page-loading indicator below the toolbar."""
    def __init__(self) -> None:

        super().__init__()

        self.setFixedHeight(2)

        self._progressValue : float = 0.0
        self._opacityValue : float = 0.0
        self._isFinishing : bool = False

        self._progressAnimation: QPropertyAnimation = QPropertyAnimation(self, b"progress", self)
        self._progressAnimation.setEasingCurve(QEasingCurve.Type.OutCubic)
        self._progressAnimation.finished.connect(self._afterFill)

        self._opacityAnimation: QPropertyAnimation = QPropertyAnimation(self, b"fade", self)
        self._opacityAnimation.setDuration(320)
        self._opacityAnimation.finished.connect(self._afterFade)

    def _getProgress(self) -> float: return self._progressValue

    def _setProgress(self, progressValue : float) -> None:

        self._progressValue = progressValue

        self.update()

    def _getOpacity(self) -> float:

        return self._opacityValue

    def _setOpacity(self, opacityValue : float) -> None:

        self._opacityValue = opacityValue

        self.update()

    progress = pyqtProperty(float, _getProgress, _setProgress)

    fade = pyqtProperty(float, _getOpacity, _setOpacity)

    def _animate(self, targetValue : float, durationMilliseconds : int) -> None:

        self._progressAnimation.stop()
        self._progressAnimation.setDuration(durationMilliseconds)
        self._progressAnimation.setStartValue(self._progressValue)
        self._progressAnimation.setEndValue(targetValue)
        self._progressAnimation.start()

    def start(self) -> None:

        self._progressAnimation.stop()

        self._opacityAnimation.stop()

        self._isFinishing = False

        self._progressValue = 0.0

        self._opacityValue = 1.0

        self.update()

        self._animate(0.1, 300)

    def setProgress(self, value : float) -> None:

        if not self._isFinishing:

            self._animate(max(value / 100.0, 0.1), 350)

    def finish(self) -> None:

        self._isFinishing = True

        self._animate(1.0, 200)

    def reset(self) -> None:

        self._progressAnimation.stop()

        self._opacityAnimation.stop()

        self._isFinishing = False
        
        self._progressValue = 0.0

        self._opacityValue = 0.0

        self.update()

    def _afterFill(self) -> None:

        if self._isFinishing:
            
            self._opacityAnimation.stop()
            self._opacityAnimation.setStartValue(self._opacityValue)
            self._opacityAnimation.setEndValue(0.0)
            self._opacityAnimation.start()

    def _afterFade(self) -> None:

        if self._isFinishing:

            self._isFinishing = False

            self._progressValue = 0.0

            self.update()

    def paintEvent(self, event : QPaintEvent) -> None:

        painter : QPainter = QPainter(self)

        painter.fillRect(self.rect(), QColor("#e3e5e8"))

        if self._opacityValue > 0:

            progressColor : QColor = QColor(ACCENT)

            progressColor.setAlphaF(self._opacityValue)
        
            progressRect : QRectF = QRectF(
                0,
                0,
                self.width() * self._progressValue,
                self.height(),
            )

            painter.fillRect(progressRect, progressColor)
