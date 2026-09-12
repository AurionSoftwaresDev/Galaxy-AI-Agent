from source.models.toolModels.createFolderModel import CreateFolderModel
from source.tools.features.createFolder import createFolder
from langchain_core.tools import StructuredTool

createFolderTool : StructuredTool = StructuredTool.from_function(
    args_schema =  CreateFolderModel,
    func = createFolder,
    name = "create_folder",
    description = """
        Create a new folder at the specified path.

        Use this tool when you need to create a directory or folder for storing
        files, project resources, source code, assets, or other data.

        The tool automatically checks whether the folder already exists before
        creating it. If the folder already exists, it returns its existing path
        instead of creating it again.

        Parameters:
            path:
                The parent directory where the folder should be created.

            folderName:
                The name of the folder to create.

            parents:
                Determines whether missing parent directories should also be
                created. Use True by default when the parent path may not exist.

        Important:
            Use the exact path and folder name provided by the user or required
            by the current task.

            Prefer parents=True when creating nested directories so that missing
            parent directories are created automatically.

            If the folder already exists, do not treat it as a failure. The tool
            will return an "Already Exists" status with the folder path.
    """
)