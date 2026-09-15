import source.agent.prompts.systemPrompt as systemPrompt
from source.provider.llmProviders import llmProviders
from langchain.agents import create_agent
from source.tools.webSearchTool import webSearchTool
from source.tools.datetimeFetchingTool import fetchCurrentDateTimeTool
from source.tools.sendEmaillTool import sendEmailTool
from source.tools.openBrowserTool import openBrowserTool
from source.tools.TypingTool import typingTool
from source.tools.inspectUserSystemTool import inspectUserSystemTool
from source.tools.createFileTool import createFileTool
from source.tools.readFileTool import readFileTool
from source.tools.deleteFileTool import deleteFileTool
from source.tools.createFolderTool import createFolderTool
from source.tools.deleteFolderTool import deleteFolderTool
from source.tools.launchDesktopApplicationTool import launchApplicationTool
from source.tools.archiveCompressorTool import archiveCompressorTool

### LLM Provider Model ###
'''
Your Provider It's Depend You What Are You Choose :) In Gemini, Mistral And Ollama Go And Add 
Your Provider In /backendsource/providers/llmProvider.py And Use "llmProvider.<yourProviderName>" 
'''
llmProviderModel = llmProviders.geminiProvider

### Creating AI Agent Use Locally Ollama LLM Model 'llmProviderModel' Variable ###
agent = create_agent(
    model = llmProviderModel,
    system_prompt = systemPrompt.prompt,
    tools = [
        fetchCurrentDateTimeTool,
        webSearchTool,
        sendEmailTool,
        openBrowserTool,
        typingTool,
        inspectUserSystemTool,
        createFolderTool,
        deleteFolderTool,
        createFileTool,
        readFileTool,
        deleteFileTool,
        launchApplicationTool,
        archiveCompressorTool
    ],
)