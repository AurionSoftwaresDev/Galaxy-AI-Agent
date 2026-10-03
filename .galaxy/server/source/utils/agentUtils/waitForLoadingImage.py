import time
import pyautogui
from source.utils.logger import logger

def waitForImage(imagePath : str, timeout : float = 10.0) -> bool:

    startTime = time.time()

    logger.info("AI Agent Waiting For Loading")

    while time.time() - startTime < timeout:

        location = pyautogui.locateOnScreen(image = imagePath, confidence = 0.8)

        if location is not None:

            logger.info("iamge Loaded Successfully")

            return True

    logger.exception("Image Not Loaded.")

    return False