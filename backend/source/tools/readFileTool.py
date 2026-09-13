from source.models.toolModels.readFileModel import ReadFileModel
from source.tools.features.readFile import readFile
from langchain_core.tools import StructuredTool

readFileTool : StructuredTool = StructuredTool.from_function(
    args_schema = ReadFileModel,
    func = readFile,
    name = "read_file",
    description = """
        Use this tool when you need to inspect, understand, analyze, or retrieve
        the contents of an existing text-based file.

        Parameters:
            filePath:
                The directory path containing the file.

            fileName:
                The name of the file to read. Nested paths are supported.

        Important:
            Always provide the correct directory path and file name.

            Use this tool before modifying an existing file when you need to
            understand its current contents.

            If the specified file does not exist, the tool returns a structured
            "File Not Found" response instead of raising a FileNotFoundError.

            This tool reads the file as text, so it should primarily be used for
            text-based files such as Python, JavaScript, TypeScript, JSON, HTML,
            CSS, Markdown, YAML, TXT, and similar files.
    """
)