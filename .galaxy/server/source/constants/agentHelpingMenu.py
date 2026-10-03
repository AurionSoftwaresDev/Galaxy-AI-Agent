HELPING_MENU : str = """
        Galaxy AI Launcher
        ==================

        Usage:
            python startGalaxy.py
            python startGalaxy.py server=true
            python startGalaxy.py agent=true
            python startGalaxy.py server=true agent=true
            python startGalaxy.py server=false agent=false

        Options:
            server=true     Start the FastAPI server.
            server=false    Do not start the FastAPI server.

            agent=true      Start the interactive AI agent.
            agent=false     Do not start the interactive AI agent.

        Behavior:
            No arguments
                Starts both the server and agent.

            Only server/agent arguments
                Starts only the components enabled with true.

            -h, --help
                Show this usage menu.

        Examples:
            python startGalaxy.py
                Start server + agent.

            python startGalaxy.py server=true
                Start only the server.

            python startGalaxy.py agent=true
                Start only the agent.

            python startGalaxy.py server=true agent=true
                Start both.

            python startGalaxy.py server=false
                Start only the agent.

            python startGalaxy.py agent=false
                Start only the server.
"""
