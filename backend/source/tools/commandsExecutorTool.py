from source.models.toolModels.commandsExecutorModel import CommandExecutorInputModel
from source.tools.features.executeCommands import commandsExecutor
from langchain_core.tools import StructuredTool

commandsExecutorTool : StructuredTool = StructuredTool.from_function(
    args_schema = CommandExecutorInputModel,
    func = commandsExecutor,
    name = "commands_executor",
    description = """
        Execute one or more system shell commands sequentially.

        Returns each command's output, success status, exit code,
        and current working directory.

        Examples:
        - ["echo Hello"]
        - ["cd Desktop", "dir"]

    """
)