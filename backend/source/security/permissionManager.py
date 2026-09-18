import questionary
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from source.utils.logger import logger

class PermissionManager():

    def __init__(
            self, data : dict[str, str],
            beforePrompt : function = None,
            afterPrompt : function = None
        ):

        self.userChoiceOptions : list = [
            "Allow",
            "Deny"
        ]

        self.beforePrompt       =   self.beforePrompt
        self.afterPrompt        =   self.afterPrompt

        self.ToolName : str     =   data["tool_name"]
        self.title : str        =   data["title"]
        self.details : str      =   data["details"]

        self.content : Text     =   Text()

        self.console : Console  =   Console()

        self.content.append(text = f"AI Agent Permission Required For \"{ self.ToolName }\" Tool\n", style = "bold")
        self.content.append(text = f"{self.title}\n")
        self.content.append(text = f"{self.details}\n\n",style = "dim")

    def askPermission(self) -> bool | dict[str, str | bool]:

        if self.beforePrompt:

            self.beforePrompt()

        logger.info(f"AI Agent Ask Permission For \"{ self.ToolName }\" Tool Execution")

        self.console.print(
            Panel(
                renderable = self.content,
                border_style = "cyan",
                padding = (1, 2),
                expand = False
            )
        )

        userPermission = questionary.select(
            "Allow This Operation?",
            choices = self.userChoiceOptions,
            pointer = ">"
        ).ask()

        if self.afterPrompt:

            self.afterPrompt()

        if userPermission.lower() == "allow":

            logger.info(f"""User \"Allowed\" To Execute \"{ self.ToolName }\" Tool
                                          ^^^^^^^^^
                """
            )

            return True

        logger.info(f"""User \"Deny\" To Execute \"{ self.ToolName }\" Tool
                                          ^^^^^^
            """
        )
        
        return {
            "Success": False,
            "Status": "Permission Denied!",
            "Tool Name": self.ToolName,
            "Information": f"User Denied For This { self.ToolName } Tool Operation"
        }
