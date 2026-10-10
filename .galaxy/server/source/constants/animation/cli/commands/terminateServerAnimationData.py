from source.config.configs import getServerURL

ANIMATION_STEPS_QUEUE = [
    (
        "Target Host Base", 
        f"[white]{ getServerURL }[/white]"
    ),
    (
        "Termination Request", 
        "[bold yellow]SENT ➔[/bold yellow]"
    ),
    (
        "Active Process State", 
        "[bold red]TERMINATED ✖[/bold red]"
    ),
    (
        "System Gateway Pipeline", 
        "[bold red]OFFLINE ○[/bold red]"
    )
]
