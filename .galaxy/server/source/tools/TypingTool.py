import json
import time
from langchain_core.tools import tool
from source.models.toolModels.TypingModel import TypingModel
from source.utils.logger import logger

# Try to import PyAutoGUI for OS-level GUI control
try:

    import pyautogui

    HAS_PYAUTOGUI = True

except ImportError:

    HAS_PYAUTOGUI = False

# Try to import Keyboard as a fallback mechanism
try:

    import keyboard

    HAS_KEYBOARD = True

except ImportError:

    HAS_KEYBOARD = False

@tool(
    args_schema=  TypingModel,
    description = """
        Useful for typing text into the user's computer keyboard or active window.
        
        Use this tool when the user explicitly requests to type, enter, write, or input 
        text into the currently active text box, application, or command line interface.
        
        Input: Accepts the exact string under the 'text' key.
        
        Behavior: The tool automatically handles a 3-second delay internally to let the 
        user click on the target input field before it starts typing. It types the text 
        exactly as provided with a slight character delay and presses 'Enter' at the end.
        
        Rules: Never modify, summarize, translate, or rewrite the text string unless 
        specifically instructed by the user. Pass the text exactly as requested.
    """,
    name_or_callable = "typing_text"
)
def typingTool(text : str, wait_time: float = 3.0) -> str:

    delay: float = 0.05

    logger.info("AI Agent Called typing_text Tool...")
    
    # Internal delay to allow user to focus on the target window
    time.sleep(wait_time)

    # Strategy 1: Attempt using PyAutoGUI
    if HAS_PYAUTOGUI:

        try:

            pyautogui.write(text, interval=delay)

            pyautogui.press("enter")

            logger.info("AI Agent Typed Successfully using PyAutoGUI!")

            return json.dumps(obj=[
                {
                    "Status": "Typed",
                    "Given Typing Text": text
                }
            ], indent = 4)

        except Exception as e:

            logger.error(f"AI Agent Failed To Type. PyAutoGUI failed: {e}. Trying fallback...")

    # Strategy 2: Fallback to Keyboard Module
    if HAS_KEYBOARD:

        try:

            keyboard.write(text, delay=delay)

            keyboard.press("enter")

            logger.info("AI Agent Typed Successfully using Keyboard module!")

            return json.dumps(obj=[
                {
                    "Status": "Typed",
                    "Given Typing Text": text  # Fixed the 'Gaven' typo here
                }
            ], indent=  4)
        
        except Exception as exception:

            logger.critical(f"AI Agent Failed To Type. Keyboard Fallback Also Failed : {exception}")            
    else:

        logger.critical("Both PyAutoGUI and Keyboard modules are unavailable or failed.")
    
    # Return failure response if both methods fail
    return json.dumps([
        {
            "Status": "Failed",
            "Given Typing Text": text
        }
    ], indent=4)
