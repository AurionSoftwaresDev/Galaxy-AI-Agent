import sys
import ctypes
from ctypes import wintypes
from typing import Dict, Any

class KernelMetricsEngine:
    """
    A high-performance, memory-safe engine designed to fetch peak-level 
    kernel diagnostics across Windows, Linux, and macOS without subprocessing.
    """
    
    def __init__(self):

        self.os_type = sys.platform

    def collect(self) -> Dict[str, Any]:
        """Routes to the correct OS collector and packages data with metadata."""

        metrics = {
            "os_platform": self.os_type,
            "kernel_data": {}
        }
        
        if self.os_type.startswith("win"):

            metrics["kernel_data"] = self._get_windows_kernel()

        elif self.os_type.startswith("linux"):

            metrics["kernel_data"] = self._get_linux_kernel()

        elif self.os_type.startswith("darwin"):

            metrics["kernel_data"] = self._get_macos_kernel()

        else:

            metrics["kernel_data"] = {"error": f"Unsupported platform: {self.os_type}"}
            
        return metrics

    def _get_windows_kernel(self) -> Dict[str, Any]:

        class PERFORMANCE_INFORMATION(ctypes.Structure):

            _fields_ = [
                ("cb", wintypes.DWORD),
                ("CommitTotal", ctypes.c_size_t),
                ("CommitLimit", ctypes.c_size_t),
                ("CommitPeak", ctypes.c_size_t),
                ("PhysicalTotal", ctypes.c_size_t),
                ("PhysicalAvailable", ctypes.c_size_t),
                ("SystemCache", ctypes.c_size_t),
                ("KernelTotal", ctypes.c_size_t),
                ("KernelPaged", ctypes.c_size_t),
                ("KernelNonpaged", ctypes.c_size_t),
                ("PageSize", ctypes.c_size_t),
                ("HandleCount", wintypes.DWORD),
                ("ProcessCount", wintypes.DWORD),
                ("ThreadCount", wintypes.DWORD),
            ]

        try:

            psapi = ctypes.WinDLL('psapi.dll')

            perf_info = PERFORMANCE_INFORMATION()

            perf_info.cb = ctypes.sizeof(PERFORMANCE_INFORMATION)
            
            if psapi.GetPerformanceInfo(ctypes.byref(perf_info), perf_info.cb):

                pg = perf_info.PageSize

                return {
                    "Status": "Success",
                    "Active Handles": perf_info.HandleCount,
                    "Active Threads": perf_info.ThreadCount,
                    "Active Processes": perf_info.ProcessCount,
                    "Karnel Memory Total MB": (perf_info.KernelTotal * pg) // 1048576,
                    "Kernel Paged Pool MB": (perf_info.KernelPaged * pg) // 1048576,
                    "Kernel Nonpaged Pool Mb": (perf_info.KernelNonpaged * pg) // 1048576
                }
            
            return {"Status": "Failed", "Error": "GetPerformanceInfo returned False"}
        
        except Exception as e:

            return {"Status": "Error", "Error": str(e)}

    def _get_linux_kernel(self) -> Dict[str, Any]:

        data = {"status": "success", "slab_allocations": {}}
        
        # 1. Read Max Kernel Threads (Optimized single line read)
        try:

            with open("/proc/sys/kernel/threads-max", "r") as f:

                data["max_kernel_threads"] = int(f.read().strip())

        except (FileNotFoundError, ValueError):

            data["max_kernel_threads"] = None

        # 2. Read Kernel Boot Flags
        try:

            with open("/proc/cmdline", "r") as f:

                data["kernel_boot_flags"] = f.read().strip().split()

        except FileNotFoundError:

            data["kernel_boot_flags"] = []

        # 3. Stream and slice Slab Memory Allocator stats (Memory optimized cache processing)
        try:
            
            with open("/proc/slabinfo", "r") as f:

                next(f); next(f)  # Skip header lines

                for _ in range(5):

                    line = f.readline()

                    if not line: 

                        break

                    parts = line.split()

                    if len(parts) >= 4:

                        data["slab_allocations"][parts[0]] = {
                            "active_objects": int(parts[1]),
                            "total_objects": int(parts[2]),
                            "object_size_bytes": int(parts[3])
                        }

        except FileNotFoundError:
            data["slab_allocations"] = "Access Denied / Not Found"
            
        return data

    def _get_macos_kernel(self) -> Dict[str, Any]:

        data = {"status": "success"}

        try:

            libc = ctypes.CDLL(None)

            def _sysctl_str(name: str) -> str:

                size = ctypes.c_size_t(0)

                libc.sysctlbyname(name.encode(), None, ctypes.byref(size), None, 0)

                if size.value == 0: 

                    return ""

                buf = ctypes.create_string_buffer(size.value)

                libc.sysctlbyname(name.encode(), buf, ctypes.byref(size), None, 0)

                return buf.value.decode(errors='ignore').strip()

            data["xnu_version"] = _sysctl_str("kern.version")
            data["boot_arguments"] = _sysctl_str("kern.bootargs")
            
            # Read an integer property securely
            size_int = ctypes.c_size_t(ctypes.sizeof(ctypes.c_int))

            max_proc = ctypes.c_int()

            libc.sysctlbyname(b"kern.maxproc", ctypes.byref(max_proc), ctypes.byref(size_int), None, 0)

            data["max_process_limit"] = max_proc.value

        except Exception as e:

            return {"status": "error", "error": str(e)}
            
        return data