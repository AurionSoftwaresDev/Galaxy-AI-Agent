import GPUtil, psutil, platform, subprocess

def getHardwareInformation() -> dict[str, str]:

    hardwareInformation = {}

    gpuList = []
    
    diskList = []

    systemOS = platform.system()

    cpuFrequency  = psutil.cpu_freq()

    uname : platform.uname_result = platform.uname()
    
    motherboard = {"manufacturer": "Unknown", "product": "Unknown", "bios_version": "Unknown"}

    cpuInformations = {
        "CPU Cores Informations" : {
            "Processor/CPU" :  f"{uname.processor}",
            "Physical Cores" :  f"{psutil.cpu_count(logical=False)}",
            "Logical Cores" :  f"{psutil.cpu_count(logical=True)}",
            "Max Frequency MHZ": cpuFrequency.max if cpuFrequency else None,
            "Current Frequency MHZ": cpuFrequency.current if cpuFrequency else None,
            "Current CPU Usage Percent": psutil.cpu_percent(interval=0.5)
        }
    }

    try:

        gpus = GPUtil.getGPUs()

        for gpu in gpus:
            gpuList.append({
                "Id": gpu.id,
                "Name": gpu.name,
                "Load_percent": f"{gpu.load * 100:.1f}%",
                "Memory Total MB": gpu.memoryTotal,
                "Memory Used MB": gpu.memoryUsed,
                "Memory Free MB": gpu.memoryFree,
                "Temperature Celsius": gpu.temperature
            })
    except Exception:

        gpuList = ["No dedicated NVIDIA GPU detected or GPUtil incompatible"]

    for partition in psutil.disk_partitions():

        try:

            usage = psutil.disk_usage(partition.mountpoint)

            diskList.append({
                "Device": partition.device,
                "Mountpoint": partition.mountpoint,
                "File System Type": partition.fstype,
                "Total GB": round(usage.total / (1024**3), 2),
                "Used GB": round(usage.used / (1024**3), 2),
                "Free GB": round(usage.free / (1024**3), 2),
                "Percent Used": usage.percent
            })

        except PermissionError:
    
            continue

    try:
        
        if systemOS == "Windows":

            mbVendor = subprocess.check_output(
                args = 'powershell -NoProfile -Command "(Get-CimInstance Win32_BaseBoard).Manufacturer"',
                shell=True
            ).decode().strip()

            mbProduct = subprocess.check_output(
                'powershell -NoProfile -Command "(Get-CimInstance Win32_BaseBoard).Product"',
                shell=True
            ).decode().strip()

            biosVersion = subprocess.check_output(
                'powershell -NoProfile -Command "(Get-CimInstance Win32_BIOS).SMBIOSBIOSVersion"',
                shell=True
            ).decode().strip()
            
            motherboard["Manufacturer"] = mbVendor
            motherboard["Product"] = mbProduct
            motherboard["Bios Version"] = biosVersion

        elif systemOS == "Linux":
            
            try:

                motherboard["Manufacturer"] = open("/sys/class/dmi/id/board_vendor").read().strip()
                motherboard["Product"] = open("/sys/class/dmi/id/board_name").read().strip()
                motherboard["Bios Version"] = open("/sys/class/dmi/id/bios_version").read().strip()

            except:

                pass
                
        elif systemOS == "Darwin": 

            motherboardInformation = subprocess.check_output("system_profiler SPHardwareDataType", shell=True).decode()

            for line in motherboardInformation.split('\n'):

                if "Model Identifier" in line:

                    motherboard["Product"] = line.split(":")[1].strip()

                if "Boot ROM Version" in line or "System Firmware Version" in line:

                    motherboard["Bios Version"] = line.split(":")[1].strip()

            motherboard["Manufacturer"] = "Apple Inc."
            
    except Exception as e:

        motherboard["Error"] = f"Could not retrieve motherboard details: {str(e)}"

    hardwareInformation["CPU Informations"] = cpuInformations
    hardwareInformation["GPU Informations"] = gpuList
    hardwareInformation["Storage Informations"] = diskList
    hardwareInformation["Motherboard Informations"] = motherboard

    return hardwareInformation