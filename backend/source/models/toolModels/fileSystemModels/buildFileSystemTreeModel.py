from typing import Literal
from pydantic import BaseModel, Field

class BuildFileSystemTreeModel(BaseModel):
    """
        Input schema for the buildTree tool.

        This model defines the arguments required to inspect and return
        the directory/file structure of a given filesystem path.
    """

    path : str = Field(
        description="""
            The absolute or relative filesystem path whose structure should
            be inspected.

            IMPORTANT:
            - This must be a valid filesystem path.
            - The path can point to either a file or a directory.
            - If the path points to a directory, its children will be recursively
            inspected.
            - If the path points to a file, information about that file will be
            returned instead of a directory tree.
            - Prefer using an absolute path when the user has provided one.
            - Do not invent a path.
            - If the user provides a path explicitly, use that exact path.
            - Windows paths are supported, for example:
            "C:\\Users\<username>\\Desktop\\project"
            - Linux/macOS paths are supported, for example:
            "/home/user/project"
            "/Users/user/project"

            The path is the ROOT of the tree that will be generated.
        """
    )

    type : Literal["COMMAND", "JSON"] = Field(
        default = "JSON",
        description = """
            Determines the format and method used to generate the filesystem tree.

            Available modes:

            1. "JSON"
                - This is the DEFAULT mode.
                - Use this mode when the agent needs to understand, inspect,
                    parse, reason about, or process the filesystem structure.
                - The result is returned as a JSON string.
                - Directories contain a "children" list.
                - Files contain their name, path, and type.
                - Example directory structure returned in JSON:

                {
                    "name": "project",
                    "path": "C:\\\\project",
                    "type": "directory",
                    "children": [
                        {
                            "name": "main.py",
                            "path": "C:\\\\project\\\\main.py",
                            "type": "file"
                        }
                    ]
                }

            - JSON mode is generally the preferred mode for AI-agent
                filesystem reasoning.

            2. "COMMAND"
                - Uses the operating system's `tree` command to generate a
                    human-readable tree representation.
                - On Windows, the system `tree` command is used with file
                    information.
                - On Linux/macOS, the `tree` command must be installed on the
                    system.
                - The result is plain text rather than structured JSON.
                - Use this mode when the user specifically wants a terminal-like
                    or human-readable tree output.
                - Do NOT prefer this mode when the agent needs to programmatically
                    reason about individual files/directories but it's better then json becacuse it's return real tree format data and more readable.

            IMPORTANT:
                - The value must be exactly "JSON" or "COMMAND".
                - "JSON" is the recommended/default choice for agent operations.
                - The comparison is case-insensitive internally, but always provide
            one of the documented values.
        """
    )