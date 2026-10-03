from typing import Optional
from pydantic import BaseModel, Field

class ArchiveExtractorInputModel(BaseModel):

    format : str = Field(
        description = """
            The archive format of the archive to extract.

            Supported formats:
                - .zip
                - .tar
                - .7z
                - .rar

                Provide only the format of the archive being extracted.

                Note: Provide format with add "." dot 
                    
                    Exmaple format = ".zip"
        """
    )

    archiveSourceFullPath : str = Field(
        description = """
            The complete path to the archive file that should be extracted.

            Example:
            C:/Users/<username>/Desktop/myArchive.zip
        """
    )

    archiveExtractOutputPath : str = Field(
        description = """
            The complete directory path where the archive contents should
            be extracted.

            This must be a directory path, not the final extracted folder path.
        """
    )

    archiveOutputNameFolder : Optional[str] = Field(
        default = None,
        description = """
            Optional name of the folder that will contain the extracted
            archive contents.

            If omitted, the archive name is used automatically after removing
            its file extension and formatting the first character as uppercase.

            Example:
            myArchive.zip → MyArchive
        """
    )

    archivePassword : Optional[str] = Field(
        default = None,
        description = """
            Optional password required to extract the archive.

            Provide this only when the archive is password protected.

            If the archive requires a password and no password is provided,
            the tool returns a structured response indicating that a password
            is required instead of raising an error.
        """
    )