import pyautogui, time
from langchain_core.tools import tool
from source.models.TypingModel import TypingModel

@tool(
    args_schema = TypingModel,
    description = """
        Type text into user's web browser.description=
        
        Use this tool then the user asks to type, enter, or write text. into the browser, such as 
        entering a search query or filling in text
    """,
    name_or_callable = "type_text"
)
def typingTool(text : str):

    time.sleep(3)

    pyautogui.write(text, interval=0.05)

    pyautogui.press("enter")