from langchain_core.tools import StructuredTool
from source.tools.features.webSearch import webSearch
from source.models.webSearchModel import WebSearchSchema

webSearchTool : StructuredTool = StructuredTool.from_function(
    func = webSearch,
    name = "fetching_news",
    description = (
        "Fetch the latest news from internet."
        "Use this tool whenever the user asks for latest, recent, "
        "today's, breaking, or current news"    
    ),
    args_schema = WebSearchSchema
)