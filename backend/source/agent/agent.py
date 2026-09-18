import source.agent.prompts.systemPrompt as systemPrompt
from source.provider.llmProviders import llmProviders
from langchain.agents import create_agent
from source.tools.webSearchTool import webSearchTool
from source.tools.datetimeFetchingTool import fetchCurrentDateTimeTool
from source.tools.sendEmaillTool import sendEmailTool
from source.tools.openBrowserTool import openBrowserTool
from source.tools.TypingTool import typingTool
from source.tools.inspectUserSystemTool import inspectUserSystemTool
from source.tools.fileSystem.createFileTool import createFileTool
from source.tools.fileSystem.readFileTool import readFileTool
from source.tools.fileSystem.deleteFileTool import deleteFileTool
from source.tools.fileSystem.createFolderTool import createFolderTool
from source.tools.fileSystem.deleteFolderTool import deleteFolderTool
from source.tools.fileSystem.buildFileSystemTreeTool import buildFileSystemTreeTool
from source.tools.fileSystem.archive.archiveCompressorTool import archiveCompressorTool
from source.tools.fileSystem.archive.archiveExtractorTool import archiveExtractorTool
from source.tools.launchDesktopApplicationTool import launchApplicationTool

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
        buildFileSystemTreeTool,
        archiveCompressorTool,
        archiveExtractorTool,
        
        launchApplicationTool,
    ],
)