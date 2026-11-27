from __future__ import annotations

import json
import os
import sys
from collections.abc import Callable
from functools import partial
from pathlib import Path
from typing import Any, cast, override

# Suppress unnecessary QtWebEngine and Chromium logs.
os.environ["QT_LOGGING_RULES"] = (
    "*.debug=false;"
    "js.debug=false;"
    "qt.webenginecontext.debug=false"
)

os.environ["QTWEBENGINE_CHROMIUM_FLAGS"] = (
    "--log-level=3 "
    "--disable-logging"
)

from PyQt6.QtCore import (
        QCoreApplication,
        QEasingCurve,
        QPropertyAnimation,
        QSize,
        QStandardPaths,
        Qt,
        QTimer,
        QUrl,
)
from PyQt6.QtGui import QIcon, QKeySequence, QPixmap, QShortcut, QShowEvent
from PyQt6.QtWebEngineCore import (
        QWebEnginePage,
        QWebEngineProfile,
        QWebEngineSettings,
)
from PyQt6.QtWebEngineWidgets import QWebEngineView
from PyQt6.QtWidgets import (
        QHBoxLayout,
        QLabel,
        QMainWindow,
        QMenu,
        QSizePolicy,
        QStackedWidget,
        QTabBar,
        QToolButton,
        QVBoxLayout,
        QWidget,
)
from source.tools.features.browser.browserProgressiveLine import ProgressLine
from source.tools.features.browser.browserTabBar import TabBar
from source.tools.features.browser.browserToast import Toast
from source.tools.features.browser.browserUrlPill import UrlPill
from source.utils.browserUtils import (
        buildStartPage,
        findAsset,
        makeIcon,
        resolveInput,
)

from source.applicationInstance import application_main_instance
from source.config.browerConfigurations import APP_NAME, ICON_PATH, STYLE

LOGO = findAsset(ICON_PATH)


class BrowserPage(QWebEnginePage):

        def __init__(self, profile: QWebEngineProfile, window : BrowserWindow, parent: QWidget) -> None:
            
            super().__init__(profile, parent)

            self._window: BrowserWindow = window

        def createWindow(self, windowType: QWebEnginePage.WebWindowType) -> QWebEnginePage | None:

            openInBackground: bool = windowType == QWebEnginePage.WebWindowType.WebBrowserBackgroundTab

            view : WebView = self._window.addTab(blank = True, switch = not openInBackground)

            return view.page()

        @override
        def javaScriptConsoleMessage(
            self,
            level: QWebEnginePage.JavaScriptConsoleMessageLevel,
            message: str,
            lineNumber: int,
            sourceID: str
        ) -> None:
            """Suppress JavaScript console messages from websites."""
            return

class WebView(QWebEngineView):

    def __init__(self, profile : QWebEngineProfile, window : BrowserWindow) -> None:

        super().__init__()

        self.isLoading : bool = False
        
        self.setPage(BrowserPage(profile, window, self))

class BrowserWindow(QMainWindow):

    def __init__(self, start_urls : list[str] | None = None) -> None:

        super().__init__()

        self.setWindowTitle(APP_NAME)

        self.resize(1280, 800)

        self.setMinimumSize(640, 420)

        LOGO = findAsset(ICON_PATH)

        if LOGO:
            
            self.setWindowIcon(QIcon(str(LOGO)))
            
        self.setStyleSheet(STYLE)

        self._hasBeenShown : bool = False
        self._closedTabUrls : list[QUrl] = []
        self._developerToolsViews : list[QWebEngineView] = []
        self.startPageHtml : str = buildStartPage()

        self._buildUi()

        # Create the profile after the UI to keep destruction order safe.
        self.profile : QWebEngineProfile = self._makeProfile()
        self.toast : Toast = Toast(self)

        self._setupShortcuts()
        self.setWindowOpacity(0.0)               # The window fades in through showEvent.

        urls : list[QUrl | None] = [resolveInput(targetUrl) for targetUrl in (start_urls or [])]

        urls = [targetUrl for targetUrl in urls if targetUrl]

        if urls:

            for targetUrl in urls:

                self.addTab(targetUrl)
        else:

            self.addTab()

    # Setup
    def _makeProfile(self) -> QWebEngineProfile:
        
        profileDataPath: Path = (
            Path(
                QStandardPaths.writableLocation(
                    QStandardPaths.StandardLocation.AppDataLocation
                )
            )
            / "profile"
        )

        profileDataPath.mkdir(parents=True, exist_ok=True)

        # Persistent login sessions and cookies.
        webProfile : QWebEngineProfile = QWebEngineProfile("galaxy_profile", self)

        webProfile.setPersistentStoragePath(str(profileDataPath))
        webProfile.setCachePath(str(profileDataPath / "cache"))
        webProfile.setPersistentCookiesPolicy(
            QWebEngineProfile.PersistentCookiesPolicy.ForcePersistentCookies
        )
        webProfile.setHttpCacheType(QWebEngineProfile.HttpCacheType.DiskHttpCache)

        webSettings : QWebEngineSettings | None = webProfile.settings()
        webAttributes : type[QWebEngineSettings.WebAttribute] = QWebEngineSettings.WebAttribute
        enabledAttributes : tuple[QWebEngineSettings.WebAttribute, ...] = (
            webAttributes.ScrollAnimatorEnabled,
            webAttributes.FullScreenSupportEnabled,
            webAttributes.PluginsEnabled,
            webAttributes.PdfViewerEnabled,
            webAttributes.JavascriptCanAccessClipboard,
        )

        for attribute in enabledAttributes:

            webSettings.setAttribute(attribute, True)

        webProfile.downloadRequested.connect(self._onDownload)

        return webProfile

    def _toolButton(
        self,
        icon : str,
        tooltipText : str,
        slot : Callable[..., Any],
        size : int = 34,
    ) -> QToolButton:

        toolButton : QToolButton = QToolButton()

        toolButton.setIcon(makeIcon(icon))
        toolButton.setIconSize(QSize(18, 18))
        toolButton.setFixedSize(size, size)
        toolButton.setToolTip(tooltipText)
        toolButton.setCursor(Qt.CursorShape.PointingHandCursor)
        toolButton.clicked.connect(slot)

        return toolButton

    def _buildUi(self) -> None:

        centralWidget : QWidget = QWidget()
        rootLayout : QVBoxLayout = QVBoxLayout(centralWidget)
        tabStrip : QWidget = QWidget()
        tabStripLayout : QHBoxLayout = QHBoxLayout(tabStrip)
        toolbarWidget : QWidget = QWidget()

        self.browserChrome : QWidget = QWidget()
        self.tabBar : TabBar = TabBar()
        self.progressIndicator : ProgressLine = ProgressLine()
        self.urlBar : UrlPill = UrlPill()
        self.webViewStack : QStackedWidget = QStackedWidget()
        self.menuButton: QToolButton = self._toolButton("menu", "Menu", lambda : None)

        chromeLayout : QVBoxLayout = QVBoxLayout(self.browserChrome) 

        rootLayout.setContentsMargins(0, 0, 0, 0)
        rootLayout.setSpacing(0)
        
        chromeLayout.setContentsMargins(0, 0, 0, 0)
        chromeLayout.setSpacing(0)

        # Tab strip
        tabStrip.setObjectName("strip")
        tabStrip.setAttribute(Qt.WidgetAttribute.WA_StyledBackground, True)
        tabStrip.setFixedHeight(40)
        tabStripLayout.setContentsMargins(10, 0, 8, 0)
        tabStripLayout.setSpacing(4)

        if LOGO:

            logoLabel : QLabel = QLabel()
            logoPixmap : QPixmap = QPixmap(
                str(LOGO)
            ).scaled(
                44, 44, Qt.AspectRatioMode.KeepAspectRatio,
                Qt.TransformationMode.SmoothTransformation
            )

            logoPixmap.setDevicePixelRatio(2.0)
            logoLabel.setPixmap(logoPixmap)
            logoLabel.setContentsMargins(0, 0, 6, 0)
            tabStripLayout.addWidget(logoLabel)

        self.tabBar.setMovable(True)
        self.tabBar.setExpanding(False)
        self.tabBar.setDrawBase(False)
        self.tabBar.setDocumentMode(True)
        self.tabBar.setUsesScrollButtons(True)
        self.tabBar.setElideMode(Qt.TextElideMode.ElideRight)
        self.tabBar.setSizePolicy(QSizePolicy.Policy.Maximum, QSizePolicy.Policy.Fixed)
        self.tabBar.currentChanged.connect(self._onTabChanged)
        self.tabBar.tabMoved.connect(self._onTabMoved)
        self.tabBar.middleClicked.connect(
            lambda tabIndex : self.closeView(
                cast(WebView, self.webViewStack.widget(tabIndex))
            )
        )

        tabStripLayout.addWidget(self.tabBar)
        tabStripLayout.addWidget(self._toolButton("plus", "New tab (Ctrl+T)", self.newTab, 30))
        tabStripLayout.addStretch(1)

        # Toolbar
        toolbarWidget.setObjectName("toolbar")
        toolbarWidget.setAttribute(Qt.WidgetAttribute.WA_StyledBackground, True)
        toolbarWidget.setFixedHeight(46)

        toolbarLayout: QHBoxLayout = QHBoxLayout(toolbarWidget)
        toolbarLayout.setContentsMargins(8, 5, 8, 5)
        toolbarLayout.setSpacing(2)

        self.backButton : QToolButton = self._toolButton(
            "back",
            "Back (Alt+←)",
            lambda : self.current().back(),
        )
        self.forwardButton : QToolButton = self._toolButton(
            "forward",
            "Forward (Alt+→)",
            lambda : self.current().forward(),
        )
        self.reloadButton : QToolButton = self._toolButton(
            "reload",
            "Reload (F5)",
            self._reloadOrStop,
        )
        self.homeButton : QToolButton = self._toolButton(
            "home",
            "Home",
            lambda : self.loadHome(self.current()),
        )

        self.urlBar.edit.returnPressed.connect(self._go)
        self.urlBar.escaped.connect(self._urlEscape)

        self.menuButton.setPopupMode(QToolButton.ToolButtonPopupMode.InstantPopup)
        self.menuButton.setMenu(self._buildMenu())

        for widget in (self.backButton, self.forwardButton, self.reloadButton, self.homeButton):
            toolbarLayout.addWidget(widget)

        toolbarLayout.addSpacing(6)
        toolbarLayout.addWidget(self.urlBar, 1)
        toolbarLayout.addSpacing(6)

        toolbarLayout.addWidget(self.menuButton)

        chromeLayout.addWidget(tabStrip)
        chromeLayout.addWidget(toolbarWidget)
        chromeLayout.addWidget(self.progressIndicator)
        rootLayout.addWidget(self.browserChrome)
        rootLayout.addWidget(self.webViewStack, 1)
        self.setCentralWidget(centralWidget)

    def _buildMenu(self) -> QMenu:

        menu : QMenu = QMenu(self)

        def addMenuAction(actionText : str, callback : Callable[..., Any]) -> None:

            menu.addAction(actionText).triggered.connect(callback)

        addMenuAction("New tab\tCtrl+T", self.newTab)
        addMenuAction("Reopen closed tab\tCtrl+Shift+T", self.reopenTab)
        menu.addSeparator()
        addMenuAction("Zoom in\tCtrl++", lambda: self.zoom(+0.1))
        addMenuAction("Zoom out\tCtrl+-", lambda: self.zoom(-0.1))
        addMenuAction("Reset zoom\tCtrl+0", lambda: self.zoom(None))
        menu.addSeparator()
        addMenuAction("Full screen\tF11", self.toggleFullscreen)
        addMenuAction("Developer tools\tF12", self.openDevtools)

        return menu

    def _setupShortcuts(self) -> None:

        def registerShortcuts(
            shortcutKeys : str | list[str] | tuple[str, ...],
            callback : Callable[..., Any],
        ) -> None: 

            shortcutKeyList : list[str] | tuple[str, ...] = (

                shortcutKeys

                if isinstance(shortcutKeys, (list, tuple))

                else [shortcutKeys]
            )

            for shortcutKey in shortcutKeyList:

                shortcut : QShortcut = QShortcut(QKeySequence(shortcutKey), self)

                shortcut.activated.connect(callback)

        registerShortcuts("Ctrl+T", self.newTab)
        registerShortcuts("Ctrl+W", lambda : self.closeView(self.current()))
        registerShortcuts("Ctrl+Shift+T", self.reopenTab)
        registerShortcuts("Ctrl+L", self.focusUrl)
        registerShortcuts(["F5", "Ctrl+R"], self._reloadOrStop)
        registerShortcuts(
            "Ctrl+Shift+R",
            lambda : self.current().triggerPageAction(
                QWebEnginePage.WebAction.ReloadAndBypassCache
            ),
        )

        registerShortcuts("Alt+Left", lambda : self.current().back())
        registerShortcuts("Alt+Right", lambda : self.current().forward())
        registerShortcuts("Alt+Home", lambda : self.loadHome(self.current()))
        registerShortcuts("Ctrl+Tab", lambda : self._cycleTab(+1))
        registerShortcuts("Ctrl+Shift+Tab", lambda : self._cycleTab(-1))
        registerShortcuts(["Ctrl++", "Ctrl+="], lambda : self.zoom(+0.1))
        registerShortcuts("Ctrl+-", lambda : self.zoom(-0.1))
        registerShortcuts("Ctrl+0", lambda : self.zoom(None))
        registerShortcuts("F11", self.toggleFullscreen)
        registerShortcuts("F12", self.openDevtools)

    # Tabs
    def current(self) -> WebView:

        return cast(WebView, self.webViewStack.currentWidget())

    def addTab(
        self,
        targetUrl : QUrl | None = None,
        switch : bool = True,
        blank : bool = False,
    ) -> WebView:

        webView : WebView = WebView(self.profile, self)

        self.webViewStack.addWidget(webView)

        tabIndex : int = self.tabBar.addTab(makeIcon("globe", "#80868b"), "New Tab")
        closeButton : QToolButton = QToolButton()

        closeButton.setObjectName("tabclose")
        closeButton.setIcon(makeIcon("close"))
        closeButton.setIconSize(QSize(12, 12))
        closeButton.setFixedSize(20, 20)
        closeButton.setCursor(Qt.CursorShape.PointingHandCursor)
        closeButton.clicked.connect(partial(self.closeView, webView))

        self.tabBar.setTabButton(tabIndex, QTabBar.ButtonPosition.RightSide, closeButton)

        webView.titleChanged.connect(partial(self._onTitle, webView))
        webView.iconChanged.connect(partial(self._onIcon, webView))
        webView.urlChanged.connect(partial(self._onUrl, webView))
        webView.loadStarted.connect(partial(self._onLoadStarted, webView))
        webView.loadProgress.connect(partial(self._onLoadProgress, webView))
        webView.loadFinished.connect(partial(self._onLoadFinished, webView))
        webView.page().fullScreenRequested.connect(self._onPageFullscreen)

        if targetUrl is not None:

            webView.setUrl(targetUrl)

        elif not blank:

            self.loadHome(webView)

        if switch:

            self.tabBar.setCurrentIndex(tabIndex)

        return webView

    def newTab(self) -> None:

        self.addTab()

        QTimer.singleShot(0, self.focusUrl)

    def loadHome(self, view : WebView) -> None:
        
        view.setHtml(self.startPageHtml)

    def closeView(self, view : WebView) -> None:

        tabIndex = self.webViewStack.indexOf(view)

        if tabIndex < 0:

            return

        tabUrl : QUrl = view.url()

        if tabUrl.isValid() and tabUrl.scheme() not in ("about", "data", ""):

            self._closedTabUrls.append(tabUrl)

        if self.tabBar.count() == 1:

            self.close()

            return

        self.webViewStack.removeWidget(view)

        self.tabBar.removeTab(tabIndex)

        view.deleteLater()

    def reopenTab(self) -> None:

        if self._closedTabUrls:

            self.addTab(self._closedTabUrls.pop())

    def _cycleTab(self, tabStep : int) -> None:

        tabCount : int = self.tabBar.count()

        if tabCount:

            self.tabBar.setCurrentIndex((self.tabBar.currentIndex() + tabStep) % tabCount)

    def _onTabChanged(self, tabIndex : int) -> None:

        if tabIndex < 0 or tabIndex >= self.webViewStack.count():

            return

        self.webViewStack.setCurrentIndex(tabIndex)
        
        self._syncChrome(cast(WebView, self.webViewStack.widget(tabIndex)))

    def _onTabMoved(self, fromIndex : int, toIndex : int) -> None:

        webView : WebView = cast(WebView, self.webViewStack.widget(fromIndex))

        self.webViewStack.removeWidget(webView)
        self.webViewStack.insertWidget(toIndex, webView)
        self.webViewStack.setCurrentIndex(self.tabBar.currentIndex())

    # View callbacks
    def _isCurrent(self, view : WebView) -> bool:

        return view is self.current()

    def _onTitle(self, view : WebView, title : str) -> None:

        tabIndex = self.webViewStack.indexOf(view)

        if tabIndex < 0:

            return

        tabTitle : str = title or "New Tab"

        self.tabBar.setTabText(tabIndex, tabTitle)
        self.tabBar.setTabToolTip(tabIndex, tabTitle)

        if self._isCurrent(view):

            self.setWindowTitle(f"{tabTitle} - {APP_NAME}")

    def _onIcon(self, view : WebView, icon : QIcon) -> None:

        tabIndex = self.webViewStack.indexOf(view)

        if tabIndex >= 0:
            
            self.tabBar.setTabIcon(
                tabIndex,
                icon if not icon.isNull() else makeIcon("globe", "#80868b"),
            )

    def _onUrl(self, view: WebView, changedUrl : QUrl) -> None:

        if self._isCurrent(view):

            self._setUrlText(view)

            self._updateNav()

    def _onLoadStarted(self, view : WebView) -> None:

        view.isLoading = True

        if self._isCurrent(view):

            self.progressIndicator.start()

            self._setReloadState(True)

    def _onLoadProgress(self, view: WebView, loadProgress : int) -> None:

        if self._isCurrent(view):

            self.progressIndicator.setProgress(loadProgress)

    def _onLoadFinished(self, view: WebView, loadSucceeded : bool) -> None:
        
        view.isLoading = False

        if self._isCurrent(view):

            self.progressIndicator.finish()

            self._setReloadState(False)

            self._updateNav()

    # Browser chrome synchronization
    def _syncChrome(self, view : WebView) -> None:

        self._setUrlText(view, force=True)

        self._updateNav()

        self._setReloadState(view.isLoading)
        
        if view.isLoading:

            self.progressIndicator.start()

        else:

            self.progressIndicator.reset()

        tabIndex = self.webViewStack.indexOf(view)
        tabTitle = self.tabBar.tabText(tabIndex) if tabIndex >= 0 else ""

        self.setWindowTitle(f"{tabTitle} - {APP_NAME}" if tabTitle else APP_NAME)

    def _setUrlText(self, view : WebView, force : bool = False) -> None:

        if not force and self.urlBar.edit.hasFocus():

            return

        currentUrl : QUrl = view.url()
        urlScheme : str = currentUrl.scheme()

        if urlScheme in ("about", "data", ""):

            urlText : str = ""
            securityState : str = "none"

        else:

            urlText : str = currentUrl.toString()
            securityState : str = {"https": "secure", "http": "insecure"}.get(urlScheme, "none")

        self.urlBar.edit.setText(urlText)
        self.urlBar.edit.setCursorPosition(0)
        self.urlBar.setState(securityState)

    def _updateNav(self) -> None:

        currentView : WebView = self.current()

        if currentView:

            self.backButton.setEnabled(currentView.history().canGoBack())
            self.forwardButton.setEnabled(currentView.history().canGoForward())

    def _setReloadState(self, loading : bool) -> None:

        self.reloadButton.setIcon(makeIcon("close" if loading else "reload"))
        self.reloadButton.setToolTip("Stop loading" if loading else "Reload (F5)")

    def _reloadOrStop(self) -> None:

        currentView : WebView = self.current()
        currentView.stop() if currentView.isLoading else currentView.reload()

    # URL bar
    def _go(self) -> None:

        targetUrl : QUrl | None = resolveInput(self.urlBar.edit.text())

        if targetUrl:

            currentView: WebView = self.current()
            currentView.setUrl(targetUrl)
            currentView.setFocus()

    def _urlEscape(self) -> None:

        self._setUrlText(self.current(), force=True)

        self.current().setFocus()

    def focusUrl(self) -> None:

        self.urlBar.edit.setFocus()
        self.urlBar.edit.selectAll()

    # Zoom and fullscreen
    def zoom(self, zoomDelta : float | None) -> None:

        currentView : WebView = self.current()
        zoomFactor : float = (
            1.0
            if zoomDelta is None
            else min(5.0, max(0.25, currentView.zoomFactor() + zoomDelta))
        )

        currentView.setZoomFactor(round(zoomFactor, 2))
        self.toast.showMessage(f"Zoom {round(zoomFactor * 100)}%", 1200)

    def toggleFullscreen(self) -> None:

        if self.isFullScreen():

            self.browserChrome.show()

            self.showNormal()

        else:

            self.browserChrome.hide()

            self.showFullScreen()

    # Handle video fullscreen requests.
    def _onPageFullscreen(self, fullscreenRequest : Any) -> None:

        fullscreenRequest.accept()

        if fullscreenRequest.toggleOn():

            self.browserChrome.hide()

            self.showFullScreen()

        else:

            self.browserChrome.show()

            self.showNormal()

    def openDevtools(self) -> None:

        developerToolsView : QWebEngineView = QWebEngineView()

        developerToolsView.setWindowTitle("Developer Tools")
        developerToolsView.resize(1000, 700)

        self.current().page().setDevToolsPage(developerToolsView.page())

        developerToolsView.show()

        self._developerToolsViews.append(developerToolsView)

    # Downloads
    def _onDownload(self, downloadItem : Any) -> None:

        downloadFolder : Path = Path.home() / "Downloads"

        downloadFolder.mkdir(exist_ok=True)

        downloadItem.setDownloadDirectory(str(downloadFolder))

        downloadFileName : str = downloadItem.downloadFileName()

        downloadItem.accept()

        self.toast.showMessage(f"Downloading {downloadFileName}...")

        downloadItem.isFinishedChanged.connect(

            lambda : self.toast.showMessage(f"Downloaded: {downloadFileName}")
            if downloadItem.isFinished()
            else None
        )

    # Window events
    def showEvent(self, event : QShowEvent) -> None:

        super().showEvent(event)

        if not self._hasBeenShown:

            self._hasBeenShown = True
            
            self._fadeAnimation: QPropertyAnimation = QPropertyAnimation(
                self,
                b"windowOpacity",
                self,
            )

            self._fadeAnimation.setDuration(450)
            self._fadeAnimation.setStartValue(0.0)
            self._fadeAnimation.setEndValue(1.0)
            self._fadeAnimation.setEasingCurve(QEasingCurve.Type.OutCubic)
            self._fadeAnimation.start()

    # =======================================================================
    # AGENT API - The agent will use these methods to control the browser.
    # =======================================================================
    def openUrl(self, targetUrl : str, newTab : bool = False) -> None:

        targetQUrl : QUrl | None = resolveInput(targetUrl)

        if targetQUrl is None:

            return

        if newTab:

            self.addTab(targetQUrl)

        else:

            self.current().setUrl(targetQUrl)

    def runJs(self, javaScript : str, resultCallback : Callable[[Any], None] | None = None) -> None:

        """Execute JavaScript and pass the result to the callback, if provided."""

        currentPage : QWebEnginePage | None = self.current().page()

        if resultCallback:
            
            currentPage.runJavaScript(javaScript, resultCallback)

        else:

            currentPage.runJavaScript(javaScript)

    def getHtml(self, htmlCallback : Callable[[str], None]) -> None:

        self.current().page().toHtml(htmlCallback)

    def getText(self, textCallback : Callable[[str], None]) -> None:
        
        self.current().page().toPlainText(textCallback)

    def screenshot(self, filePath : str | Path) -> bool:

        return self.current().grab().save(str(filePath))

def start_browser() -> None:

    QCoreApplication.setAttribute(Qt.ApplicationAttribute.AA_ShareOpenGLContexts)

    application_main_instance.setApplicationName(APP_NAME)
    
    application_main_instance.setStyle("Fusion")

    if LOGO:

        application_main_instance.setWindowIcon(QIcon(str(LOGO)))

    startUrls : list[str] = [
        argument
        for argument in sys.argv[1:]
        if not argument.startswith("-")
    ]
    browserWindow : BrowserWindow = BrowserWindow(startUrls)

    browserWindow.show()
    
    exitCode : int = application_main_instance.exec()

    del browserWindow

    sys.exit(exitCode)

    return json.dumps(
        obj = [
            {
                "Success": True,
                "Status": 0,
                "Message": "Browser Opened! But User Closed!"
            }
        ], 
        indent = 4
    )

def stop_browser() -> str:

    application_main_instance.quit()

    return json.dump(
        obj = [
            {
                "Success": True,
                "Status": 0,
                "Message": "Browser Successfully Closed!"
            }
        ],
        indent = 4
    )