from source.models.toolModels.fileSystemModels.deleteFolderModel import DeleteFolderModel
from source.tools.features.fileSystemFeatures.deleteFolder import deleteFolder
from langchain_core.tools import StructuredTool


deleteFolderTool : StructuredTool = StructuredTool.from_function(
    args_schema = DeleteFolderModel,
    func = deleteFolder,
    name = "delete_folder",
    description = """
        Delete an existing folder from the filesystem.

        Use this tool when you need to remove a directory or folder.

        Parameters:
            folderPath:
                The parent directory containing the folder that should be deleted.

            folderName:
                The name of the folder that should be deleted.

            recursive:
                Determines whether the folder contents should also be deleted.

                When False:
                    Only an empty folder can be deleted. This is the safe default.

                When True:
                    The folder and all files and subfolders inside it are deleted
                    recursively.

        Important:
            Always verify the folder path and folder name before deleting it.

            Keep recursive=False unless the task explicitly requires deleting the
            folder together with its contents.

            Do not use recursive=True merely because the folder is not empty.

            This tool returns a structured status when the folder does not exist,
            when the specified path is not a directory, or when the operating
            system prevents deletion.

            Use delete_file when you need to delete a single file instead of a
            folder.
    """
)