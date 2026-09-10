from langchain_core.tools import StructuredTool
from source.models.inspectUserSystemModel import InspectUserSystemModel
from source.tools.features.inspectUserSystem import inspectUserSystem

inspectUserSystemTool : StructuredTool = StructuredTool.from_function(
    func = inspectUserSystem,
    name = "inspect_user_system",
    args_schema = InspectUserSystemModel,
    description = """
        
    """ 
)