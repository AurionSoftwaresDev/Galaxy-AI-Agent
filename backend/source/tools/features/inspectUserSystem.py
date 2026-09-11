import platform, psutil, getpass, os, subprocess, json
from datetime import datetime
from source.utils.logger import logger
from source.utils.agentUtils.getHardwareInformation import getHardwareInformation

def inspectUserSystem():

    logger.info("AI Agent Called inspect_user_system Tool")

    uname : platform.uname_result = platform.uname()

    bootTimeTimeStamp : float = psutil.boot_time()

    bootTime : datetime = datetime.fromtimestamp(bootTimeTimeStamp)

    virtualMemory = psutil.virtual_memory()

    users = psutil.users()

    activeSessions = []

    logger.info("AI Agent Fetching User System Details")

    for user in users:

        try:

            log_time = datetime.fromtimestamp(user.started).strftime("%Y-%m-%d %H:%M:%S")

        except:

            log_time = "Unknown"

        activeSessions.append({
            "Username": user.name,
            "Terminal": user.terminal,
            "Host": user.host,
            "Logged In At": log_time
        })

    allRegisteredAccounts = []

    if platform.system() == "Windows":
       
        try:
          
            out = subprocess.check_output("net user", shell=True).decode('utf-8', errors='ignore')

            lines = out.split('\n')

            startParsing = False

            for line in lines:

                if '----' in line:

                    startParsing = True

                    continue

                if startParsing:

                    if "The command completed successfully" in line:

                        break
                    
                    parts = [name.strip() for name in line.split() if name.strip()]

                    allRegisteredAccounts.extend(parts)

        except Exception:

            allRegisteredAccounts = ["Error parsing Windows accounts"]

    else:

        import pwd

        allRegisteredAccounts = [user.pw_name for user in pwd.getpwall()]

    hardwareInformation = getHardwareInformation()
    
    inspectedUserSystemData = {
        "System Informations" : {
            "Operating System" : f"{uname.system} {uname.release}",
            "Operating System Version" : f"{uname.version}",
            "Machine Node" : f"{uname.node}",
            "Architecture" : f"{uname.machine} ({platform.architecture()[0]})",
            "Boot Time" : f"{bootTime.year}/{bootTime.month}/{bootTime.day} {bootTime.hour}:{bootTime.minute}:{bootTime.second}",

            "Ram Informations" : {
                "Total Memory" : f"{virtualMemory.total / (1024**3):.2f} GB",
                "Available Memory" : f"{virtualMemory.available / (1024**3):.2f} GB"
            }
        },
        "Hardware Information" : hardwareInformation,
        "Users Informations" : {
            "Current User" : f"{getpass.getuser()}",
            "User Home Directory" : f"{os.path.expanduser('~')}",
            "Current Session User": getpass.getuser(),
            "Currently Logged In Users": activeSessions,
            "All Registered System Accounts": allRegisteredAccounts
        }
    }

    jsonInspectedUserSystemData : str = json.dumps(inspectedUserSystemData, indent = 4)

    logger.info("AI Agent Successfully Fetched User System Details")

    return jsonInspectedUserSystemData

print(inspectUserSystem())