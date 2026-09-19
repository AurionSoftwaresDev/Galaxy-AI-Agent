import json
import platform
import subprocess
import threading
import uuid

from source.utils.logger import logger
from source.security.permissionManager import PermissionManager
from source.utils.TerminalUI import TerminalUI

class CommandExecutor:

    def __init__(self):
        
        logger.info("AI Agent Initialize Command Executor")

        self.userOperatingSystem = platform.system()

        self.isWindows = self.userOperatingSystem == "Windows"

        self.markerPrefix = f"__GALAXY_{uuid.uuid4().hex}__"

        self.process = self._createProcess()

        self.stdoutLock = threading.Lock()

    def _createProcess(self):

        if self.isWindows:

            shellCommand = [
                "cmd.exe",
                "/Q",
                "/D"
            ]
            
        else:

            shellCommand = [
                "/bin/bash"
            ]

        return subprocess.Popen(
            args    =   shellCommand,
            stdin   =   subprocess.PIPE,
            stdout  =   subprocess.PIPE,
            stderr  =   subprocess.STDOUT,
            text    =   True,
            bufsize =   1
        )

    def _createMarker(self) -> str:

        return f"{ self.markerPrefix }_{ uuid.uuid4().hex }"

    def _cleanOutputLine(self, line : str) -> str | None:

        if line.startswith("Microsoft Windows [Version"):

            return None

        if line.startswith("(c) Microsoft Corporation"):

            return None

        if line.startswith("(.venv)") and ">" in line:

            return line.split(">", 1)[1]

        return line

    def _writeCommand(self, command: str) -> None:

        self.process.stdin.write(f"{ command }\n")

        self.process.stdin.flush()

    def _readUntilMarker(self, marker : str) -> tuple[list[str], int | None]:

        output = []

        exitCode = None

        while True:

            line = self.process.stdout.readline()

            if not line:

                break

            line = line.rstrip("\r\n")

            if marker in line:

                parts = line.split()

                try:

                    exitCode = int(parts[-1])

                except (ValueError, IndexError):

                    exitCode = None

                break

            line = self._cleanOutputLine(line)

            if line is not None:

                output.append(line)

        return output, exitCode

    def _getCurrentDirectory(self) -> str:

        marker = self._createMarker()

        if self.isWindows:

            command = f"cd\necho { marker }"

        else:

            command = f"pwd\necho { marker } $?"

        self.process.stdin.write(f"{command}\n")

        self.process.stdin.flush()

        currentDirectory = []

        while True:

            line = self.process.stdout.readline()

            if not line:

                break

            line = line.rstrip("\r\n")

            if marker in line:

                break

            line = self._cleanOutputLine(line)

            if line is not None:
                
                currentDirectory.append(line)

        return "\n".join(currentDirectory).strip()

    def _executeCommand(self, command : str) -> dict:

        marker = self._createMarker()

        if self.isWindows:

            wrappedCommand = (
                f"{ command }\n"
                f"echo { marker } %errorlevel%\n"
            )
        else:
            wrappedCommand = (
                f"{ command }\n"
                f"echo { marker } $?\n"
            )

        self.process.stdin.write(wrappedCommand)
        self.process.stdin.flush()

        output, exitCode = self._readUntilMarker(marker = marker)

        currentDirectory = self._getCurrentDirectory()

        return {
            "Command": command,
            "Current Directory": currentDirectory,
            "Success": exitCode == 0,
            "Exit Code": exitCode,
            "Command Output": "\n".join(output).strip()
        }

    def execute(self, commands : list[str]) -> str:

        if not commands:

            return json.dumps(
                obj = {
                    "Status": "No Commands Provided",
                    "Commands": []
                },
                indent = 4
            )

        commandsOutput = []

        with self.stdoutLock:

            for command in commands:

                if not command or not command.strip():
                    
                    continue

                try:

                    commandOutput = self._executeCommand(
                        command = command
                    )

                    commandsOutput.append(commandOutput)

                except Exception as exception:

                    logger.exception(f"AI Agent Problem Command Execution : { exception }")

                    commandsOutput.append(
                        {
                            "Command": command,
                            "Current Directory": self._getCurrentDirectory(),
                            "Success": False,
                            "Exit Code": None,
                            "Command Output": str(object = exception)
                        }
                    )

        return json.dumps(
            {
                "Command Executed": len(commandsOutput),
                "Commands Outputs": commandsOutput
            },
            indent = 4
        )

    def close(self) -> None:

        if self.process.poll() is not None:

            return

        try:
            
            self.process.stdin.write("exit\n")

            self.process.stdin.flush()

            self.process.wait(timeout = 5)

        except subprocess.TimeoutExpired:

            logger.warning("AI Agent Problem Command Executor did not close gracefully. Force terminating process.")

            self.process.kill()

        except Exception as exception:

            logger.exception(f"AI Agent Problem Closing Command Executor : { exception }")

            self.process.kill()



def commandsExecutor(commands : list[str]):

    terminalUI = TerminalUI()

    permissionManager = PermissionManager(
        data = {
            "tool_name": "commands_executor",
            "title": "AI Agent Wants To Run Commands : ",
            "details": commands
        },
        beforePrompt = terminalUI.pause,
        afterPrompt = terminalUI.resume()
    )

    userPermission = permissionManager.askPermission()

    if isinstance(userPermission, dict):

        return json.dumps(
            obj = userPermission,
            indent = 4
        )

    commandExecutor = CommandExecutor()

    try:

        return commandExecutor.execute(commands = commands)

    finally:

        commandExecutor.close()