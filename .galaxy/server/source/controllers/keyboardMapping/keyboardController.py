import os
import platform
import threading

import keyboard

from source.constants.keyboardShortcuts import agentShortCuts, clearScreenShortCut
from source.utils.agentUtils.core.handleAgentShortcuts import handleAgentShortcuts
from source.utils.helper import clearTerminalScreen
from source.utils.logger import logger


def handleAllShortcutsAndKeyBinds():

    stopSignal = threading.Event()
    
    currentOperatingSystem : str = platform.system()

    keyboard.add_hotkey(hotkey = clearScreenShortCut, callback = clearTerminalScreen, args=(currentOperatingSystem,))
    
    for agentShortcut in agentShortCuts:

        keyboard.add_hotkey(hotkey = agentShortcut, callback = handleAgentShortcuts, args=(agentShortcut,))

    while True:    
        
        while not stopSignal.is_set():

            try:
                
                keyboard.wait()
                
            except (
                KeyboardInterrupt,
                OSError,
                AttributeError
            ) as exception:
                
                logger.exception(f"AI Agent Failed To Perform Keyboard Shortcut. Exception: { exception }")

                stopSignal.set()
                
                os._exit(1)

        