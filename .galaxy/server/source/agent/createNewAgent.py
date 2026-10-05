import source.agent.prompts.systemPrompt as systemPrompt

from source.provider.llmProviders import llmProviders
from langchain.agents import create_agent

from source.agent.agentTools import AGENT_TOOLS

### Creating AI Agent Use Locally Ollama LLM Model 'llmProviderModel' Variable ###
def createNewAgent(llmProviderModel):
    
    agent = create_agent(
        model = llmProviderModel,
        system_prompt = systemPrompt.prompt,
        tools = AGENT_TOOLS
    )

    return agent