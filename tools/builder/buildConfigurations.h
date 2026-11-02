# pragma once

# include <string>

namespace buildPaths {

    const std::string AGENT_FILE_PATH = "client";

    const std::string SERVER_FILE_PATH = "server";
}

namespace buildFileName {

    const std::string SERVER_FILE = "buildServer";

    const std::string AGENT_FILE = "buildAgent";
}

namespace colors {

    const std::string RED = "\033[31m";

    const std::string RESET = "\033[0m";
}

namespace FLAGS {

    std::string SERVER_FLAG = "--server";
    
    std::string AGENT_FLAG = "--agent";
}