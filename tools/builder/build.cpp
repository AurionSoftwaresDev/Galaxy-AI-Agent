# include "buildConfigurations.h"
# include "executeScript.h"
# include "helper.h"

# include <iostream>
# include <vector>

using namespace buildPaths;
using namespace buildFileName;
using namespace colors;
using namespace FLAGS;
using namespace helpers;

using namespace std;

int main(int argc, char** argv) {

    if (argc > 3) {

        cerr << RED << "[Error] Your ARGs Must Be 2 Or 1 But Give " << argc - 1 << RESET << endl;

        print_help_menu();
    }

    bool user_server_flag = NULL;
    bool user_agent_frontend_flag = NULL;
    bool show_use_menu = false;

    vector<string> given_flags = {};

    for (int index = 1; index <= argc - 1; index++)  {

        string extracted_flag = (string) (char* ) argv[index];

        if (extracted_flag == SERVER_FLAG) user_server_flag = true;

        if (extracted_flag == AGENT_FLAG) user_agent_frontend_flag = true; 

        if (extracted_flag == "-h" || extracted_flag == "--help") { 

            print_help_menu();
            
            return 0;
        }

        if (extracted_flag != SERVER_FLAG && extracted_flag != AGENT_FLAG) {

            cerr << RED << "[Error] Invalid Flag : " << extracted_flag << RESET << endl;        

            print_help_menu();

            break;
        }

        given_flags.push_back(extracted_flag);
    }

    ExecuteScript executeScript;

    cout << "FLAGS USING : ";

    for (string flag : given_flags) cout << flag << ",";

    if (user_agent_frontend_flag == false && user_server_flag == false && given_flags.size() == 0) {
        
        cerr << RED << "[Error] FLAGs Are Empty : " << RESET << endl;
        
        cout << "Automaticlly Selecting " << SERVER_FLAG << ", " << AGENT_FLAG << endl;
        cout << "Build Starting..." << endl;

        executeScript.runScript(buildPaths::SERVER_FILE_PATH, buildFileName::SERVER_FILE);
        executeScript.runScript(buildPaths::AGENT_FILE_PATH, buildFileName::AGENT_FILE);

        return 0;
    }

    if (user_server_flag) {
        
        executeScript.runScript(buildPaths::SERVER_FILE_PATH, buildFileName::SERVER_FILE);
    }

    else if (user_agent_frontend_flag) {

        executeScript.runScript(buildPaths::AGENT_FILE_PATH, buildFileName::AGENT_FILE);
    }

    return 0;
}