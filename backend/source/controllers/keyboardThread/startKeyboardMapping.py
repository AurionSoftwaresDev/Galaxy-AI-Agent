import threading
from source.controllers.keyboardMapping.keyboardController import handleAllShortcutsAndKeyBinds

def startKeyboardMappingThread():
    
    thread = threading.Thread(target = handleAllShortcutsAndKeyBinds, daemon = True)
    thread.start()
