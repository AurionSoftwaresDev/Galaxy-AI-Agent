from source.models.toolModels.fileSystemModels.buildFileSystemTreeModel import BuildFileSystemTreeModel
from source.tools.features.fileSystemFeatures.buildTree import buildTree
from langchain_core.tools import StructuredTool

buildFileSystemTreeTool : StructuredTool = StructuredTool.from_function(
    args_schema = BuildFileSystemTreeModel,
    func = buildTree,
    name = "build_file_system_tree",
    buildTreeToolDescription = """
        Inspects a filesystem path and builds a tree representation of its files
        and directories.

        Use this tool when you need to understand or inspect the structure of a
        file or directory.

        Arguments:
            - path: The filesystem path to inspect.
            - type: Output mode. Use "JSON" by default, or "COMMAND" when a
        terminal-style tree output is specifically requested.

        The JSON mode is recommended for agent reasoning because it returns a
        structured representation.

        Example:
        build_tree(path="C:\\Users\\dell\\Desktop\\Agent-AI", type="JSON")

        Example:
        build_tree(path="/home/user/project", type="COMMAND")
    """
)