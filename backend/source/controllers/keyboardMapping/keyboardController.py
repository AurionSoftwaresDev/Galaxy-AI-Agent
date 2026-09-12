import os, platform, keyboard, threading
from source.utils.helper import clearTerminalScreen
from source.constants.keyboardShortcuts import ( 
    clearScreenShortCuts, 
    agentShortCuts
)
from source.utils.logger import logger
from source.utils.agentUtils.core.handleAgentShortcuts import handleAgentShortcuts


def handleAllShortcutsAndKeyBinds():

    stopSignal = threading.Event()
    
    currentOperatingSystem : str = platform.system()

    for clearScreenShortcut in clearScreenShortCuts:
                    
        keyboard.add_hotkey(hotkey = clearScreenShortcut, callback = clearTerminalScreen, args=(currentOperatingSystem,))
    
    for agentShortcut in agentShortCuts:

        keyboard.add_hotkey(hotkey = agentShortcut, callback = handleAgentShortcuts, args=(agentShortcut,))

    while True:    
        
        while not stopSignal.is_set():

            try:
                
                keyboard.wait()
                
            except Exception as exception:
                
                logger.exception(f"AI Agent Failed To Perform Keyboard Shortcut. Exception: { exception }")

                stopSignal.set()
                
                os._exit(1)

        