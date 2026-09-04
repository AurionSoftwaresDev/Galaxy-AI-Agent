import os, platform, keyboard, threading
from source.utils.helper import clearTerminalScreen
from source.constants.keyboardShortcuts import clearScreenShortcuts

stopSignal = threading.Event()

def handleAllShortcutsAndKeyBinds():
    
    currentOperatingSystem : str = platform.system()
    
    while not stopSignal.is_set():
        for clearScreenShortcut in clearScreenShortcuts:
                
                keyboard.add_hotkey(clearScreenShortcut, clearTerminalScreen, args=(currentOperatingSystem,))
                
        try:
            
            keyboard.wait()
            
        except Exception as exception:
            
            print("Unexpected Exception.")

            stopSignal.set()
            
            os._exit(1)