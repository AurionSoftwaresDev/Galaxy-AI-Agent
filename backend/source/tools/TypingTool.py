import pyautogui, time
from langchain_core.tools import tool
from source.models.TypingModel import TypingModel
from source.utils.logger import logger

@tool(
    args_schema = TypingModel,
    description = """
        Type the provided text using the keyboard computer keyboard.

        Use this tool when the user asks you to type, enter, or write text into the
        currently active application or input field.

        The tool receives the exact text that should be typed.

        After receving the text, it waits for 3 second to allow the target application or input field
        to become text Using PyAutoGUI.

        Type the text exactly as provided. Do not modify, summarize, translate, or rewrite the text
        unless the user explicitly asks for a modification.

        The 3-second delay is handled internally by the tool
    """,
    name_or_callable = "typing_text"
)
def typingTool(text : str):

    logger.info("AI Agent Called typing_text Tool..")

    time.sleep(3)

    pyautogui.write(text, interval=0.05)

    pyautogui.press("enter")

    logger.info("AI Agent Typed Successfully!")