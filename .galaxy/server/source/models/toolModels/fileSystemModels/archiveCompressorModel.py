from pathlib import Path
from pydantic import BaseModel, Field

class ArchiveCompressInputModel(BaseModel):

    sources : list[Path] = Field(
        description = """
            A list of file or directory paths that should be compressed.

            Each path must point to an existing file or directory.
            Multiple files and directories can be provided in the same request.
        """
    )

    format : str = Field(
        description="""
            The archive format to create.

            Supported formats:
            - zip
            - tar
            - 7z
            - rar

            Provide only one supported format.
        """
    )

    passwordProtected : dict[str, str | bool | None] = Field(
        description = """
            Password protection configuration for the archive.

            The dictionary contains two keys:

            "Password":
                The password to use when password protection is enabled.
                This value can be null when no password is provided and the type is string.

            "Protected":
                A boolean that determines whether password protection should
                be enabled.

                Password protection is enabled only when "Protected" is true
                and a non-empty "Password" value is provided.

                If "Protected" is false, the password is ignored even if one
                is provided.
        """
    )

    outputName : str = Field(
        description="""
            The name of the archive file that will be created.

            Include the appropriate file extension for the selected format.
        """
    )

    outputPath : Path = Field(
        description="""
            The directory where the resulting archive should be saved.

            This must be a directory path, not the complete archive file path.
        """
    )