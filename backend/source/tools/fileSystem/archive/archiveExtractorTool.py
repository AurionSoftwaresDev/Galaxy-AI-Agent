from source.models.toolModels.fileSystemModels.archiveExtractorsModel import ArchiveExtractorInputModel
from source.tools.features.archiveExtractor import archiveExtractor
from langchain_core.tools import StructuredTool

archiveExtractorTool : StructuredTool = StructuredTool.from_function(
    args_schema = ArchiveExtractorInputModel,
    func = archiveExtractor,
    name = "archive_extractor",
    description = """
        Extract an archive file into a directory.

        Use this tool when the user wants to extract, unpack, decompress,
        or open the contents of an archive.

        Supported archive formats:
            - ZIP
            - TAR
            - 7Z
            - RAR

        Arguments:

        format:

            The format of the archive.
            Supported values are ".zip", ".tar", ".7z", and ".rar".

        archiveSourceFullPath:
            The complete path to the archive file that should be extracted.

        archiveExtractOutputPath:
            The complete directory path where the extracted contents should
            be placed.

        archiveOutputNameFolder:
            Optional name of the folder that should contain the extracted
            contents.

            If omitted, the archive filename is used automatically after
            removing its extension and formatting the first character as
            uppercase.

        archivePassword:
            Optional password for password-protected archives.

            Provide this only when the archive requires a password.

            If the archive is password protected and no password is provided,
            the tool returns a structured response indicating that a password
            is required. It does not raise an error.

        Important:
            - Use the archive format specified by the user.
            - Do not invent or modify filesystem paths.
            - Preserve the user's requested output location.
            - Do not provide a password unless the user supplies one.
            - The tool returns its result as a structured JSON string.
    """
)