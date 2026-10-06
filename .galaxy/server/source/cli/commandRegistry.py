from source.cli.commands.help import help
from source.cli.commands.status import status
from source.cli.commands.tools import tools
from source.cli.commands.version import version
from source.cli.commands.exit import exit
from source.cli.commands.clear import clear
from source.cli.commands.provider import provider
from source.cli.commands.terminateServer import terminateServer

COMMAND_REGISTRY = {
    "/help": help,
    "/status": status,
    "/tools": tools,
    "/version": version,
    "/exit": exit,
    "/clear": clear,
    "/providers": provider,
    "/terminateServer": terminateServer
}