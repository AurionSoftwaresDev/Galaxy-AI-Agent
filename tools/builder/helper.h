# pragma once

# include <iostream>

using namespace std;

inline namespace helpers {
    inline void print_help_menu() {

        cout << "Usage : build <flag_1> <flag_2>" << endl;
        cout << "Flags : " << endl;
        cout << "\t--server => Server/CLI Executale Creation" << endl;
        cout << "\t--agent => Agent Frontend GUI Executable Creation" << endl;
    }
}