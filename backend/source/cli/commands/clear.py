import platform
from source.utils.helper import clearTerminalScreen

def clear():

    return clearTerminalScreen(operatingSystem = platform.system())

    