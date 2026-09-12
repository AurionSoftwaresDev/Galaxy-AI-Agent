import os
from source.agent.runAgent import startAgentAsChatMode, startAgentAsSpeakMode
from source.constants.keyboardShortcuts import KEY_MODIFIER
from source.utils.logger import logger
from source.utils.agentUtils.startupUtils.typingAnimation import typingTextOnTerminal

def handleAgentShortcuts(shortcut):

    if shortcut == f"{KEY_MODIFIER}+alt+q":

        logger.info(f"User Pressed {KEY_MODIFIER}+ALT+Q For Exit")
        logger.info("AI Agent Stopping...")

        typingTextOnTerminal(text = f"[SUCCESS] You Are Pressed {KEY_MODIFIER}+ALT+Q For Stop AI Agent")

        os._exit(0)

    if shortcut == f"{KEY_MODIFIER}+alt+shift+c":

        startAgentAsChatMode()

    if shortcut == f"{KEY_MODIFIER}+alt+r":
        
        startAgentAsSpeakMode()

    

        