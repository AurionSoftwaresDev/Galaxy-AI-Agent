import platform

userCurrentOs = platform.system()

KEY_MODIFIER :  str

if userCurrentOs == "Darwin": KEY_MODIFIER = "cmd"
if userCurrentOs == "Windows": KEY_MODIFIER = "ctrl"
else : KEY_MODIFIER = "ctrl"

clearScreenShortCut : str = f"{KEY_MODIFIER}+shift+l"

agentShortCuts : list[str] = [

    # Agent Stop 
    f"{KEY_MODIFIER}+alt+q",

    # Start AI Agent Recognization
    f"{KEY_MODIFIER}+alt+r",

    # Start Agent Chat Message
    f"{KEY_MODIFIER}+alt+shift+c"
]