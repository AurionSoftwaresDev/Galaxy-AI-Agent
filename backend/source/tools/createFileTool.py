from source.models.toolModels.createFileModel import CreateFileModel
from source.tools.features.createFile import createFile
from langchain_core.tools import StructuredTool

createFileTool : StructuredTool = StructuredTool.from_function(
    args_schema = CreateFileModel,
    func = createFile,
    name = "create_file",
    description = """
        Create a new file or write content to an existing file.

        Use this tool when you need to create a file, overwrite an existing file,
        append content to a file, or perform read/write operations using the
        specified file mode.

        The tool automatically creates the required parent directories if they
        do not already exist.

        Parameters:
            path:
                The directory path where the file should be created.

            fileName:
                The name of the file to create. Nested paths inside the file name
                are also supported.

            content:
                The text content that should be written to the file.

            mode:
                The file opening mode. Supported modes are:
                - "w": Create a new file or overwrite an existing file.
                - "a": Append content to an existing file or create it if missing.
                - "x": Create a new file and fail if the file already exists.

        Important:
            Always provide the correct file path, file name, content, and mode.
            Prefer "w" when creating or completely replacing a file.
            Use "a" only when existing content must be preserved and new content
            needs to be added.
    """
)