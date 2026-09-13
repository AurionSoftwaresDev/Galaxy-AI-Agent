from source.models.toolModels.deleteFileModel import DeleteFileModel
from source.tools.features.deleteFile import deleteFile
from langchain_core.tools import StructuredTool

deleteFileTool : StructuredTool = StructuredTool.from_function(
    args_schema = DeleteFileModel,
    func = deleteFile,
    name = "delete_file",
    description = """
        Delete an existing file from the specified directory.

        Use this tool when you need to permanently remove a file from the
        filesystem.

        Parameters:
            filePath:
                The directory path containing the file that should be deleted.

            fileName:
                The name of the file that should be deleted.

        Important:
            Always provide the correct file path and file name before calling
            this tool.

            This tool deletes files only. It cannot be used to delete directories.

            If the specified file does not exist, the tool returns a
            "File Not Found" status.

            If the operating system denies access to the file, the tool returns
            a "Permission Denied" status.

            Do not use this tool when the intention is to delete a folder.
            Use the delete_folder tool instead.
    """
)