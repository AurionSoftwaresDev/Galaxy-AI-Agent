# Agent Tools Reference & Security Model

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../README.md) • [📂 Docs Directory](./)

Galaxy AI Agent equips the LLM with **20 native desktop, system, and geospatial tools** registered in `source/agent/agentTools.py`. This document covers tool signatures, execution mechanics, parameters, and security controls.

---

## 1. Tool Catalog Summary

| Tool Name | Identifier | Category | Permission Required |
|---|---|---|:---:|
| Fetch Date & Time | `fetch_current_datetime` | System Info | No |
| Web Search | `web_search` | Information Retrieval | No |
| Send Email | `send_email` | Communication | No |
| Open Web Browser | `open_browser` | System Navigation | No |
| Typing Simulation | `typing_tool` | Automation | No |
| Inspect User System | `inspect_user_system` | System Diagnostics | No |
| Create Folder | `create_folder` | File System | No |
| Delete Folder | `delete_folder` | File System | No |
| Create File | `create_file` | File System | No |
| Read File | `read_file` | File System | No |
| Delete File | `delete_file` | File System | No |
| Build File System Tree | `build_file_system_tree` | File System | No |
| Archive Compressor | `archive_compressor` | Archiving | No |
| Archive Extractor | `archive_extractor` | Archiving | No |
| Launch Desktop App | `launch_application` | OS Desktop | No |
| Commands Executor | `commands_executor` | Shell / Terminal | **Yes (Interactive)** |
| Open Interactive Map | `open_map` | Geospatial | No |
| Fly to Location | `fly_to_location_on_map` | Geospatial | No |
| Add Coordinate Marker | `add_marker_on_coordinate_on_map` | Geospatial | No |
| Calculate Coordinate Distance | `calculate_coordinate_distance_on_map` | Geospatial | No |

---

## 2. Detailed Tool Documentation

### System & Information Tools

#### 1. `fetch_current_datetime`
- **File**: `source/tools/datetimeFetchingTool.py`
- **Purpose**: Returns the current ISO date, localized time, day of the week, and timezone.
- **Parameters**: None.
- **Output**: JSON string containing localized current timestamp and day.

#### 2. `web_search`
- **File**: `source/tools/webSearchTool.py`
- **Purpose**: Performs real-time internet search using DuckDuckGo / web scraping to fetch recent web results.
- **Parameters**:
  - `query` (str): Search phrase or question.
  - `max_results` (int, default: 5): Maximum number of search snippets to return.
- **Output**: Formatted text summary of top search results with page URLs.

#### 3. `inspect_user_system`
- **File**: `source/tools/inspectUserSystemTool.py`
- **Purpose**: Inspects hardware and platform information including OS name, release version, CPU core count, RAM usage, and active username.
- **Parameters**: None.
- **Output**: Formatted system telemetry dictionary.

---

### Communication & Navigation Tools

#### 4. `send_email`
- **File**: `source/tools/sendEmaillTool.py`
- **Purpose**: Sends emails via SMTP using the credentials configured in `.env`.
- **Parameters**:
  - `receiver_email` (str): Recipient email address.
  - `subject` (str): Email subject line.
  - `body` (str): Plain text or HTML email body.
- **Configuration**: Requires `SMTP_SENDER_EMAIL`, `SMTP_PORT`, `SMTP_SERVER_HOST`, and `SMTP_SENDER_PASSWORD` in `.env`.

#### 5. `open_browser`
- **File**: `source/tools/openBrowserTool.py`
- **Purpose**: Opens a web URL in the user's default operating system web browser.
- **Parameters**:
  - `url` (str): Valid web address (must include `http://` or `https://`).

#### 6. `typing_tool`
- **File**: `source/tools/TypingTool.py`
- **Purpose**: Simulates automated keyboard typing directly into the active desktop application or focused input field.
- **Parameters**:
  - `text` (str): Text string to type.
  - `delay` (float, default: 0.05): Inter-keystroke interval in seconds.
  - `press_enter` (bool, default: True): Whether to simulate an `Enter` keypress upon completion.

---

### File System Tools

#### 7. `create_folder`
- **File**: `source/tools/fileSystem/createFolderTool.py`
- **Purpose**: Creates directory structures recursively (`mkdir -p`).
- **Parameters**:
  - `folder_path` (str): Absolute or relative filesystem directory path.

#### 8. `delete_folder`
- **File**: `source/tools/fileSystem/deleteFolderTool.py`
- **Purpose**: Recursively deletes a directory and its contents.
- **Parameters**:
  - `folder_path` (str): Target directory path.

#### 9. `create_file`
- **File**: `source/tools/fileSystem/createFileTool.py`
- **Purpose**: Creates or overwrites a file with UTF-8 text contents, ensuring parent folders exist.
- **Parameters**:
  - `file_path` (str): Target file path.
  - `content` (str): UTF-8 text string to write.

#### 10. `read_file`
- **File**: `source/tools/fileSystem/readFileTool.py`
- **Purpose**: Reads file contents and injects them directly into the reasoning context.
- **Parameters**:
  - `file_path` (str): Path to file to read.

#### 11. `delete_file`
- **File**: `source/tools/fileSystem/deleteFileTool.py`
- **Purpose**: Deletes an individual file from the filesystem.
- **Parameters**:
  - `file_path` (str): Target file path.

#### 12. `build_file_system_tree`
- **File**: `source/tools/fileSystem/buildFileSystemTreeTool.py`
- **Purpose**: Generates an ASCII tree diagram of a directory up to a specified depth limit.
- **Parameters**:
  - `root_path` (str): Directory root to map.
  - `max_depth` (int, default: 3): Maximum recursion depth.

---

### Archiving Tools

#### 13. `archive_compressor`
- **File**: `source/tools/fileSystem/archive/archiveCompressorTool.py`
- **Purpose**: Compresses a directory into a `.zip`, `.tar`, or `.tar.gz` archive.
- **Parameters**:
  - `source_folder` (str): Folder to compress.
  - `output_archive_path` (str): Path of the destination archive.
  - `format` (str, default: `"zip"`): Compression format (`zip`, `tar`, `gztar`).

#### 14. `archive_extractor`
- **File**: `source/tools/fileSystem/archive/archiveExtractorTool.py`
- **Purpose**: Unpacks archive files into a destination directory.
- **Parameters**:
  - `archive_path` (str): Path to compressed file.
  - `destination_folder` (str): Path where files will be unpacked.

---

### OS & Desktop Automation Tools

#### 15. `launch_application`
- **File**: `source/tools/launchDesktopApplicationTool.py`
- **Purpose**: Launches desktop applications cross-platform (`explorer`/`start` on Windows, `open` on macOS, `xdg-open` or executable lookup on Linux).
- **Parameters**:
  - `app_name` (str): Name or path of the target application (e.g. `code`, `calculator`, `firefox`, `notepad`).

#### 16. `commands_executor` *(Protected by PermissionManager)*
- **File**: `source/tools/commandsExecutorTool.py`
- **Purpose**: Executes shell commands in `/bin/bash` or `cmd.exe` and captures standard output and standard error.
- **Parameters**:
  - `command` (str): Shell command line string.
- **Security Guard**: **Requires explicit user approval**. See [Section 3](#3-permission-manager--interactive-guard).

---

### Map & Geospatial Tools (MapLibre GL JS)

Galaxy AI Agent integrates an interactive 3D map engine built with MapLibre GL JS. Complete details are documented in [**Interactive Map Tools**](map_tools.md).

#### 17. `open_map`
- **File**: `source/tools/features/openMap.py` & `source/tools/mapTools.py`
- **Purpose**: Opens the interactive 3D/2D geographical map window powered by MapLibre GL JS.
- **Parameters**: None.
- **Visualization Modes**: Globe (3D), Street, Satellite, Hybrid, Terrain (3D), Buildings (3D).
- **Themes**: Stark Blue, Dark Matter, Positron Light, Voyager.

#### 18. `fly_to_location_on_map`
- **File**: `source/tools/mapTools.py`
- **Purpose**: Smoothly animates the map camera to a target latitude and longitude coordinate with custom zoom.
- **Parameters**:
  - `latitude` (float): Latitude in decimal degrees (-90.0 to 90.0).
  - `longitude` (float): Longitude in decimal degrees (-180.0 to 180.0).
  - `zoom` (float): Map zoom level (typically 1.0 to 18.0).

#### 19. `add_marker_on_coordinate_on_map`
- **File**: `source/tools/mapTools.py`
- **Purpose**: Drops a visual marker pin at the specified latitude/longitude coordinate point. Supports simultaneous multiple pins.
- **Parameters**:
  - `latitude` (float): Latitude in decimal degrees (-90.0 to 90.0).
  - `longitude` (float): Longitude in decimal degrees (-180.0 to 180.0).

#### 20. `calculate_coordinate_distance_on_map`
- **File**: `source/tools/mapTools.py`
- **Purpose**: Calculates great-circle distance between two geographical points using Haversine formula.
- **Parameters**:
  - `latitude_a` (float): Latitude of point A.
  - `longitude_a` (float): Longitude of point A.
  - `latitude_b` (float): Latitude of point B.
  - `longitude_b` (float): Longitude of point B.
- **Output**: Distance in kilometers (km).

---

## 3. Permission Manager & Interactive Guard

To protect system integrity against unauthorized command execution or destructive scripts, `commands_executor` delegates to `PermissionManager` in `source/security/permissionManager.py`:

```
+-------------------------------------------------------------+
|                     Agent Reasoning Loop                    |
|             Agent calls: commands_executor("rm -rf ...")    |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|             PermissionManager Interception Prompt           |
|                                                             |
|   [SECURITY ALERT] Agent requests to execute shell command: |
|   > rm -rf /tmp/test                                        |
|                                                             |
|   Allow execution? (y/N):                                   |
+-------------------------------------------------------------+
               /                              \
         (User says 'y')                (User says 'n')
              /                                \
             v                                  v
+------------------------+          +------------------------+
| Shell executes command |          | Execution rejected     |
| Output returned to LLM |          | Returns denial error   |
+------------------------+          +------------------------+
```

### Safety Rules
1. Non-interactive environments automatically reject unapproved shell executions.
2. In the interactive terminal, execution blocks until the operator enters `y` or `yes`.
3. Rejection returns a message to the model explaining that permission was denied by the user.

---

## 🔗 Cross-Document Reference
- [Architecture Guide](architecture.md) — Tool dispatch pipeline within the ReAct loop
- [Map Tools Guide](map_tools.md) — MapLibre GL JS integration details
- [API Reference](api.md) — Triggering tool execution over REST and WebSockets
- [CLI Reference](cli.md) — Shell command approval inside the terminal interface
