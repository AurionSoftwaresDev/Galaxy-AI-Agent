from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtGui import QMouseEvent
from PyQt6.QtWidgets import QTabBar


class TabBar(QTabBar):

    middleClicked = pyqtSignal(int)

    def mouseReleaseEvent(self, event : QMouseEvent) -> None:

        if event.button() == Qt.MouseButton.MiddleButton:
            
            tabIndex: int = self.tabAt(event.position().toPoint())
            
            if tabIndex >= 0:

                self.middleClicked.emit(tabIndex)

                return

        super().mouseReleaseEvent(event)