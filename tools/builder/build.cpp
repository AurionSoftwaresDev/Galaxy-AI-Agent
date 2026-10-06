# include <iostream>

# include "buildConfigurations.h"
# include "executeScript.h"

using namespace buildPaths;
using namespace buildFileName;

int main(void) {

    ExecuteScript executeScript;

    executeScript.runScript(buildPaths :: SERVER_FILE_PATH, buildFileName :: SERVER_FILE);
    executeScript.runScript(buildPaths :: AGENT_FILE_PATH, buildFileName :: AGENT_FILE);
}