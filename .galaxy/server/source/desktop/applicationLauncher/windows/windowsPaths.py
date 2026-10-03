import winreg, os

REGISTRY_LOCATIONS = [
    (
        winreg.HKEY_LOCAL_MACHINE,
        r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    ),
    (
        winreg.HKEY_LOCAL_MACHINE,
        r"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    ),
    (
        winreg.HKEY_CURRENT_USER,
        r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    ),
]

PROGRAM_DATA = os.environ.get(key = "PROGRAMDATA")

APP_DATA = os.environ.get(key = "APPDATA")

USER_PROFILE = os.environ.get(key ="USERPROFILE")

PUBLIC = os.environ.get(key = "PUBLIC")