from langchain_core.tools import StructuredTool
from source.models.inspectUserSystemModel import InspectUserSystemModel
from source.tools.features.inspectUserSystem import inspectUserSystem

inspectUserSystemTool : StructuredTool = StructuredTool.from_function(
    func = inspectUserSystem,
    name = "inspect_user_system",
    args_schema = InspectUserSystemModel,
    description = """
        Inspect the current system and return detailed information about the
        user's computer and active user session.

        Use this tool whenever accurate, current system information is needed
        to answer the user's request or diagnose a problem related to their
        computer.

        This includes requests or problems involving:
        - User/session information
        - Available user accounts
        - Operating system
        - CPU
        - Hardware
        - General system configuration
        - Computer-specific errors or troubleshooting

        Do not require the user to explicitly ask for "system information".
        If inspecting the current system would help answer the request
        accurately, use this tool proactively.

        Do not use this tool for general conceptual questions that do not
        depend on the user's actual computer.

        The tool returns its result as JSON.

        Treat the returned JSON as structured system information. Read and
        interpret the relevant fields before responding.
        Do not expose raw tool output unless the user explicitly asks for it.
    """ 
)