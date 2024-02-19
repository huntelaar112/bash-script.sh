#!/bin/bash

set -e
done=no
EXITEVAL=""

Name="${1}"
Exec="${2}"
Icon="${3}"
Terminal="${4}"
Type="${5}"
appfolder="/usr/share/applications"

[[ $Name = "-h" ]] && {
  echo "Content of desktop entry:
[Desktop Entry]
Name=Application-name
Exec=path-to-executable
Icon=path-to-icon
Terminal=false
Type=Application

USE: ./create-desktopapp.sh [app-name] [path-to-executable] [path-to-icon]
"
  exit 0
}

[[ $Terminal ]] || { Terminal="false"; }
[[ $Type ]] || { Type="Application"; }

contentDesktopApp="[Desktop Entry]
Name=${Name}
Exec=${Exec}
Icon=${Icon}
Terminal=false
Type=Application
"

[ ! -e "${Exec}" ] && { echo "Exec path: ${Exec} is not exist"; exit 1; }
[ ! -e "${Icon}" ] && { echo "Icon path: ${Icon} is not exist"; exit 1; }

cd "${appfolder}"
touch "${Name}.desktop"
echo "${contentDesktopApp}" > "${Name}.desktop"
chmod +x "${Name}.desktop"

done=yes