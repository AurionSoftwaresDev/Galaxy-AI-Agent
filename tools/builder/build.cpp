# include <iostream>

# include "executeScript.h"

int main(void) {

    ExecuteScript executeScript;

    executeScript.runScript("server", "buildServer");
    executeScript.runScript("client", "buildAgent");
}