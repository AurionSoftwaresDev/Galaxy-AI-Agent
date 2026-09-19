def extractProvider(agent, llmProviderModel : str) -> list[str]:

    target = llmProviderModel if llmProviderModel is not None else agent
        
    if target.__class__.__name__ == "CompiledStateGraph":

        nodes = getattr(target, "nodes", {}) or getattr(getattr(target, "builder", None), "nodes", {})

        for node_obj in nodes.values():

            runnable = getattr(node_obj, "runnable", node_obj)

            if "Chat" in runnable.__class__.__name__ or "LLM" in runnable.__class__.__name__:

                target = runnable

                break

            elif hasattr(runnable, "__closure__") and runnable.__closure__:

                for cell in runnable.__closure__:

                    cellValue = cell.cell_contents

                    if cellValue and ("Chat" in cellValue.__class__.__name__ or "LLM" in cellValue.__class__.__name__):

                        target = cellValue

                        break

    provider = target.__class__.__name__

    modelName = "Unknown Model"

    if hasattr(target, "model_name"):

        modelName = target.model_name

    elif hasattr(target, "model"):

        modelName = target.model

    elif hasattr(target, "deployment_name"):

        modelName = target.deployment_name

    return [
        provider,
        modelName
    ]