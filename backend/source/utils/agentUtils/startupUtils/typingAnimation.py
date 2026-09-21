import time, sys

def typingTextOnTerminal(text : str, speed : float = 0.09) -> str:

    for char in text:

        sys.stdout.write(char)

        sys.stdout.flush()
    
        try:

            time.sleep(speed)

        except KeyboardInterrupt:

            print("[Exception] You Are Stopped Agent Startup")

            return char

    return text
