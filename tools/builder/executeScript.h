#include <iostream>
#include <cstdlib>
#include <string>
#include <filesystem>

namespace fs = std::filesystem;

class ExecuteScript {

    private:

        inline auto getOS() -> std::string {

            #if defined(_WIN32)

                return "windows";

            #elif defined(__APPLE__)

                    return "darwin";

            #elif defined(__linux__)

                    return "linux";

            #else
            
                    return "unknown";
            #endif
        }

public:

    inline auto runScript(const std::string &subFolder, const std::string &scriptName) -> void {

        std::string os = getOS();

        fs::path rootPath = fs::current_path().parent_path().parent_path();

        fs::path scriptPath = rootPath / "scripts" / subFolder / scriptName;

        std::cout << "Script Path : " << scriptPath << std::endl;

        std::string command;

        if (os == "windows") {

            scriptPath.replace_extension(".bat");

            command = scriptPath.string();

        }
        else if (os == "linux" || os == "darwin") {

            scriptPath.replace_extension(".sh");

            command = "bash \"" + scriptPath.string() + "\"";
        }
        else {

            std::cerr << "Error: Unsupported OS type.\n";

            return;
        }

        std::cout << "Building " << subFolder << " script : " << scriptName << "...\n";

        int result = std::system(command.c_str());

        if (result == 0) {
            std::cout << "Successfully Builded!\n\n";
        }
        else {
            std::cerr << "Failed with exit code: " << result << "\n\n";
        }
    }
};