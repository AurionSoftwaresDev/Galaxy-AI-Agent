from source.models.toolModels.fileSystemModels.archiveCompressorModel import ArchiveCompressInputModel
from source.tools.features.archiveCompressors import archiveCompressor
from langchain_core.tools import StructuredTool

archiveCompressorTool : StructuredTool = StructuredTool.from_function(
    args_schema = ArchiveCompressInputModel,
    func = archiveCompressor,
    name = "archive_compressor",
    description = """
        Compress one or more files or directories into a single archive.

        Use this tool when the user wants to compress, archive, package,
        bundle, or combine files and directories into an archive.

        The tool supports the following archive formats:
            - .zip
            - .tar
            - .7z
            - .rar

            Note: Provide format with add "." dot Exmaple: format = ".rar"
        
        Arguments:

        sources:
            A list of file or directory paths to include in the archive.
            Multiple paths can be provided at the same time.
            Both individual files and directories are supported.

        format:
            The archive format to create.
            Supported values are "zip", "tar", "7z", and "rar".
            Use the format requested by the user.

        passwordProtected:
            Controls whether the resulting archive should be password protected.

            It must contain:
            - "Password": The password that should be used for encryption and the type is string.
            - "Protected": A boolean indicating whether password protection
            should be enabled.

            Password protection is enabled only when:
            "Protected" is true AND "Password" is provided.

            If "Protected" is false, the password is not used regardless of
            whether a password was provided.

            If "Protected" is true but no password is provided, the archive
            is created without password protection.

        outputName:
            The filename of the resulting archive.
            The appropriate archive extension should be included.

        outputPath:
            The directory where the resulting archive should be saved.
            Do not provide the archive filename as part of this path.

        Important:
            - Use only the supported archive formats.
            - Include all paths requested by the user in "sources".
            - Do not omit valid files or directories from the requested sources.
            - Do not invent or modify paths.
            - Use the user's requested output name and output directory.

        Important Note:
            Archives created by this tool may use strong password-based
            encryption and may not be supported by the default Windows
            archive extractor.

            If a password-protected archive cannot be opened or extracted
            using the system's default extractor, use a compatible archive
            utility such as WinRAR, 7-Zip, or another extractor that supports
            the archive's encryption format.

            If the user reports extraction or password-related problems,
            explain this limitation and suggest using a compatible extractor.
    """
)