#!/bin/bash

plus="[+]"
exception="[!]"
info="[INFO]"

echo "$info Checking The Frontend OR Backend Is Exists..."

if [ ! -d "backend" ]; then

    echo "$exception Backend Not Found At 'Agent-AI/backend'"

    exit 404
fi

if [ ! -d "frontend" ]; then

    echo "$exception Frontend Not Found At : 'Agent-AI/frontend' "

    exit 404

fi

echo "$plus Project Is Fine Exists The Backend & Frontend."


echo "$plus Checking Python Is Installed?..."

if ! command -v python3  &> /dev/null; then

    echo "$exception Python Is Not Installed. Go And Installed Python First"

    exit 404

fi

echo "$plus Python Is Installed!"

echo "$plus Checking FLutter Is Installed?..."

if ! command -v flutter &> /dev/null; then

    echo "$exception Flutter Is Not Installed. Go First And Installed Flutter"

    exit 404

fi

echo "$plus Flutter Is Installed!"

echo "$info Creating Python Virtual Enviroment(.venv) In Backend"

python -m venv "/backend/.venv"

if [ $? -eq 0 ]; then

    echo "$plus Python Virtual Enviroment Created!"

else

    echo "$exception Failed To Create Python Virtual Enviromet."

    exit 1

fi

echo "$info Activating Python Virtual Enviroment..."

if [ ! -f "backend/.venv/Scripts/activate" ]; then

    ACTIVE_SCRIPT="\backend\.venv\Scripts\activate"

else

    ACTIVE_SCRIPT="backend/.venv/bin/activate"

fi

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then

    . "$ACTIVE_SCRIPT"

else

    source "$ACTIVE_SCRIPT"

fi

echo "$info Python Virutal Enviroment Is Activated!"

echo "$info Installing Python Dependencies..."

pip install -r "backend/requirement.txt"

echo "$info Starting Backend..."

python backend/startAgent.py

echo "$plus Backend Started. Backend Running Or Agent Server"

echo "$info Starting Frontend...."

flutter run -d windows -t frontend