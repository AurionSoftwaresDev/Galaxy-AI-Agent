import time, sys

def typingTextOnTerminal(text : str, speed : float = 0.09) -> str:

    for char in text:

        sys.stdout.write(char)

        sys.stdout.flush()
    
        try:

            time.sleep(speed)

        except KeyboardInterrupt as exception:

            print("[Exception] You Are Stopped Agent Startuo")

            return char

    return text
