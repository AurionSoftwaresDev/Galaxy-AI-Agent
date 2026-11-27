import base64
import math
import re
from collections.abc import Callable
from pathlib import Path
from urllib.parse import quote_plus

from PyQt6.QtCore import QPointF, QRectF, Qt, QUrl
from PyQt6.QtGui import QColor, QIcon, QPainter, QPen, QPixmap, QPolygonF

from source.config.browerConfigurations import (
    _HOST_RE,
    APP_NAME,
    BASE_DIR,
    ICON_PATH,
    SEARCH_URL,
    START_TEMPLATE,
)

_iconCache : dict[tuple[str, str], QIcon] = {}

def findAsset(relativePath : str) -> Path | None:
    
    searchPaths: tuple[Path, Path] = (BASE_DIR, Path.cwd())
    
    for basePath in searchPaths:
    
        assetPath: Path = basePath / relativePath
    
        if assetPath.exists():
    
            return assetPath
    
    return None

def resolveInput(inputText : str) -> QUrl | None:

    inputText = inputText.strip()
    
    if not inputText:
    
        return None
    
    if re.match(r"^(https?|file|about|chrome|view-source):", inputText, re.IGNORECASE):
    
        return QUrl(inputText)
    
    if _HOST_RE.match(inputText):
     
        isLocalAddress: bool = inputText.startswith("localhost") or inputText[0].isdigit()
     
        return QUrl(("http://" if isLocalAddress else "https://") + inputText)
    
    return QUrl(SEARCH_URL + quote_plus(inputText))


def mix(startColor : QColor, endColor : QColor, blendFactor : float) -> QColor:

    return QColor(
        int(
            startColor.red() + (endColor.red() - startColor.red()) * blendFactor
        ),
        int(
            startColor.green() + (endColor.green() - startColor.green()) * blendFactor
        ),
        int(
            startColor.blue() + (endColor.blue() - startColor.blue()) * blendFactor
        )
    )

# AI Generated! :) Becuase It's Use Math :>
def _drawIcon(painter : QPainter, name : str, iconColor : QColor, iconSize : int) -> None:
    
    pen : QPen = QPen(iconColor, iconSize * 0.085)
    
    pen.setCapStyle(Qt.PenCapStyle.RoundCap)
    pen.setJoinStyle(Qt.PenJoinStyle.RoundJoin)
    
    painter.setPen(pen)
    painter.setBrush(Qt.BrushStyle.NoBrush)
    
    pointAtScale : Callable[[float, float], QPointF] = (
        lambda pointX, pointY: QPointF(pointX * iconSize, pointY * iconSize)
    )

    if name == "back":
        
        painter.drawLine(pointAtScale(.2, .5), pointAtScale(.8, .5))
        painter.drawPolyline(
            QPolygonF(
                [
                    pointAtScale(.46, .24),
                    pointAtScale(.2, .5),
                    pointAtScale(.46, .76),
                ]
            )
        )

    elif name == "forward":
        
        painter.drawLine(pointAtScale(.2, .5), pointAtScale(.8, .5))
        
        painter.drawPolyline(
            QPolygonF(
                [
                    pointAtScale(.54, .24),
                    pointAtScale(.8, .5),
                    pointAtScale(.54, .76),
                ]
            )
        )

    elif name == "reload":

        centerX : float = iconSize / 2
        centerY : float = centerX
        arcRadius : float = .29 * iconSize

        painter.drawArc(
            QRectF(
                centerX - arcRadius,
                centerY - arcRadius,
                2 * arcRadius,
                2 * arcRadius,
            ),
            50 * 16,
            280 * 16,
        )

        angleRadians : float = math.radians(50)

        arrowX = centerX + arcRadius * math.cos(angleRadians)
        arrowY = centerY - arcRadius * math.sin(angleRadians)
        
        tangentX : float = math.sin(angleRadians)
        tangentY : float = math.cos(angleRadians)
        normalX : float = -tangentY
        normalY : float = tangentX

        arrowHeadSize : float = .17 * iconSize
        arrowHead : QPolygonF = QPolygonF(
            [
                QPointF(
                    arrowX + tangentX * arrowHeadSize * .55, arrowY + tangentY * arrowHeadSize * .55
                ),
                QPointF(
                    arrowX - tangentX * arrowHeadSize * .35 + normalX * arrowHeadSize * .7,
                    arrowY - tangentY * arrowHeadSize * .35 + normalY * arrowHeadSize * .7,
                ),
                QPointF(
                    arrowX - tangentX * arrowHeadSize * .35 - normalX * arrowHeadSize * .7,
                    arrowY - tangentY * arrowHeadSize * .35 - normalY * arrowHeadSize * .7,
                )
            ]
        )

        painter.setPen(Qt.PenStyle.NoPen)
        painter.setBrush(iconColor)
        painter.drawPolygon(arrowHead)

    elif name == "close":

        painter.drawLine(pointAtScale(.28, .28), pointAtScale(.72, .72))
        painter.drawLine(pointAtScale(.72, .28), pointAtScale(.28, .72))

    elif name == "plus":
        painter.drawLine(pointAtScale(.5, .22), pointAtScale(.5, .78))
        painter.drawLine(pointAtScale(.22, .5), pointAtScale(.78, .5))

    elif name == "home":
        painter.drawPolyline(
            QPolygonF(
                [
                    pointAtScale(.17, .5),
                    pointAtScale(.5, .2),
                    pointAtScale(.83, .5),
                ]
            )
        )
        painter.drawPolyline(
            QPolygonF(
                [
                    pointAtScale(.28, .42),
                    pointAtScale(.28, .8),
                    pointAtScale(.72, .8),
                    pointAtScale(.72, .42),
                ]
            )
        )

    elif name == "menu":

        painter.setPen(Qt.PenStyle.NoPen)
        painter.setBrush(iconColor)
        
        for pointY in (.22, .5, .78):
            painter.drawEllipse(pointAtScale(.5, pointY), iconSize * .07, iconSize * .07)

    elif name == "lock":

        painter.drawArc(
            QRectF(.32 * iconSize, .16 * iconSize, .36 * iconSize, .4 * iconSize),
            0,
            180 * 16,
        )

        painter.drawLine(pointAtScale(.32, .36), pointAtScale(.32, .5))
        painter.drawLine(pointAtScale(.68, .36), pointAtScale(.68, .5))
        painter.setPen(Qt.PenStyle.NoPen)
        painter.setBrush(iconColor)
        painter.drawRoundedRect(
            QRectF(.24 * iconSize, .46 * iconSize, .52 * iconSize, .38 * iconSize),
            .07 * iconSize,
            .07 * iconSize,
        )
        
    elif name == "info":

        painter.drawEllipse(QRectF(.15 * iconSize, .15 * iconSize, .7 * iconSize, .7 * iconSize))
        painter.drawLine(pointAtScale(.5, .46), pointAtScale(.5, .68))
        painter.setPen(Qt.PenStyle.NoPen)
        painter.setBrush(iconColor)
        painter.drawEllipse(pointAtScale(.5, .31), iconSize * .05, iconSize * .05)

    elif name == "search":

        painter.drawEllipse(QRectF(.18 * iconSize, .18 * iconSize, .46 * iconSize, .46 * iconSize))
        painter.drawLine(pointAtScale(.57, .57), pointAtScale(.8, .8))

    elif name == "globe":

        painter.drawEllipse(QRectF(.14 * iconSize, .14 * iconSize, .72 * iconSize, .72 * iconSize))
        painter.drawEllipse(QRectF(.34 * iconSize, .14 * iconSize, .32 * iconSize, .72 * iconSize))
        painter.drawLine(pointAtScale(.14, .5), pointAtScale(.86, .5))

def makeIcon(
        name : str, 
        color : str = "#5f6368", 
        size : int = 64, 
) -> QIcon:

    cacheKey : tuple[str, str] = (name, color)

    if cacheKey in _iconCache:

        return _iconCache[cacheKey]

    icon : QIcon = QIcon()

    iconModes : tuple[tuple[QIcon.Mode, str], ...] = (
        (QIcon.Mode.Normal, color),
        (QIcon.Mode.Disabled, "#c4c7cc"),
    )

    for pixmapMode, pixmapModeColor in iconModes:
        
        pixmap : QPixmap = QPixmap(size, size)
        
        pixmap.fill(Qt.GlobalColor.transparent)
        painter: QPainter = QPainter(pixmap)

        painter.setRenderHint(QPainter.RenderHint.Antialiasing)
        
        _drawIcon(painter, name, QColor(pixmapModeColor), size)

        painter.end()

        icon.addPixmap(pixmap, pixmapMode)

    _iconCache[cacheKey] = icon

    return icon

def buildStartPage() -> str:

    if ICON_PATH:

        logoBase64 : str = base64.b64encode(ICON_PATH.read_bytes()).decode()
        logoMarkup : str = f'<img class="logo" alt="" src="data:image/png;base64,{logoBase64}">'

    else:

        logoMarkup : str = '<div class="logo mark">N</div>'

    return START_TEMPLATE.replace("__LOGO__", logoMarkup).replace("__NAME__", APP_NAME)
