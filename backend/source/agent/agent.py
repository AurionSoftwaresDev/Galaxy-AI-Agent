import source.agent.prompts.systemPrompt as systemPrompt
from source.provider.llmProviders import llmProviders
from langchain.agents import create_agent
from source.tools.webSearchTool import webSearchTool
from source.tools.datetimeFetchingTool import fetchCurrentDateTimeTool

### Creating AI Agent Use Locally Ollama LLM Model Qwen3 8B LLM ###
agent = create_agent(
    model = llmProviders.ollamaProvider,
    system_prompt = systemPrompt.prompt,
    tools = [
        fetchCurrentDateTimeTool,
        webSearchTool,
    ],
)
        