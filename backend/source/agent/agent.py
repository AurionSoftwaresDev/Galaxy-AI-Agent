import source.agent.prompts.systemPrompt as systemPrompt
from source.provider.llmProviders import llmProviders
from langchain.agents import create_agent
from source.tools.webSearchTool import webSearchTool
from source.tools.datetimeFetchingTool import fetchCurrentDateTimeTool
from source.tools.sendEmaillTool import sendEmailTool
from source.tools.openBrowser import openBrowserTool
from source.tools.TypingTool import typingTool
from source.tools.inspectUserSystemTool import inspectUserSystemTool

### LLM Provider Model ###
llmProviderModel = llmProviders.geminiProvider

### Creating AI Agent Use Locally Ollama LLM Model Qwen3 8B LLM ###
agent = create_agent(
    model = llmProviderModel,
    system_prompt = systemPrompt.prompt,
    tools = [
        fetchCurrentDateTimeTool,
        webSearchTool,
        sendEmailTool,
        openBrowserTool,
        typingTool,
        inspectUserSystemTool
    ],
)