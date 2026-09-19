from source.cli.commands.help import help
from source.cli.commands.status import status
from source.cli.commands.model import model
from source.cli.commands.tools import tools
from source.cli.commands.version import version
from source.cli.commands.reset import reset
from source.cli.commands.clear import clear
from source.cli.commands.config import config
from source.cli.commands.provider import provider

COMMAND_REGISTRY = {
    "/help": help,
    "/status": status,
    "/model": model, 
    "/tools": tools,
    "/version": version,
    "/reset": reset,
    "/clear": clear,
    "/config": config,
    "/provider": provider
}