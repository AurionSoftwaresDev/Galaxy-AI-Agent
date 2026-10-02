import sys, subprocess, shutil, shlex
from source.utils.logger import logger
from source.config.RootPaths import BACKEND_PATH

def startWindowsTerminal(command, title):

    """
    Opens the command inside a new CMD window
    with a custom window title.
    """

    command = [str(part) for part in command]

    subprocess.Popen(
        [
            "cmd.exe",
            "/c",
            "start",
            title,
            "cmd.exe",
            "/k",
            f"title {title} && " +
            subprocess.list2cmdline(command)
        ],
        cwd = BACKEND_PATH
    )

def startLinuxTerminal(command, title):

    command = [str(part) for part in command]

    command_string = " ".join(
        shlex.quote(part)
        for part in command
    )

    shell_command = (
        f"cd {shlex.quote(str(BACKEND_PATH))} && "
        f"printf '\\033]0;{title}\\007' && "
        f"{command_string}; "
        f"echo; "
        f"echo 'Process finished. Press Enter to close...'; "
        f"read"
    )

    # GNOME Terminal
    if shutil.which("gnome-terminal"):

        subprocess.Popen(
            [
                "gnome-terminal",
                "--title",
                title,
                "--",
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    # KDE Konsole
    if shutil.which("konsole"):

        subprocess.Popen(
            [
                "konsole",
                "--title",
                title,
                "-e",
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    # XFCE Terminal
    if shutil.which("xfce4-terminal"):

        subprocess.Popen(
            [
                "xfce4-terminal",
                "--title",
                title,
                "--",
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    # Kitty
    if shutil.which("kitty"):

        subprocess.Popen(
            [
                "kitty",
                "--title",
                title,
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    # Alacritty
    if shutil.which("alacritty"):

        subprocess.Popen(
            [
                "alacritty",
                "--title",
                title,
                "-e",
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    # xterm
    if shutil.which("xterm"):

        subprocess.Popen(
            [
                "xterm",
                "-T",
                title,
                "-e",
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    logger.exception("No Supported Linux Terminal Emulator Was Found")

    raise RuntimeError("No Supported Linux Terminal Emulator Was Found.")


def startNewTerminal(command, title):

    if sys.platform.startswith("win"):

        startWindowsTerminal(
            command,
            title
        )

        return

    if sys.platform.startswith("linux"):

        startLinuxTerminal(
            command,
            title
        )

        return

    logger.exception("Unsupprted Operating System to Run AI Agent")

    raise OSError(f"Unsupported Operating System : { sys.platform } ")