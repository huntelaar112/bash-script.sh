#!/bin/bash

set -e
#set +e # continue execute script in spite of command fail
#set -u
done=no
exitval=0

namescrpit=${0:2}

function help() {
	echo "Usage: ${namescrpit} <specific package file / auto>
  Note: This script need sudo permission to execute."
	exit ${exitval}
}

numberArgs="1"
[[ ${1} = "-h" || -z ${1} || "$#" -lt ${numberArgs} ]] && {
	echo "Missing arguments."
	help
}
source $(which logshell)
## for log-info, log-error, log-warning, log-run, log-debug, log-step

package=$1
architec=$(uname -m)
#64 bits
[[ ${architec} == "x86_64" ]] && {
	apt install linux-headers-amd64
}
#32 bits
[[ ${architec} == "i686" ]] && {
	apt install linux-headers-686
}

#list="deb http://deb.debian.org/debian/ bullseye main contrib non-free"
#echo "$list" >>/etc/apt/sources.list
sudo apt install build-essential

nvidiaCheck="/usr/bin/nvidia-smi"
[[ -e ${nvidiaCheck} ]] && {
	log-step "Uninstall existing version of nvidia-driver and libraries..."
	[[ -e "/usr/bin/nvidia-installer" ]] && {
		nvidia-installer --uninstall
		log-info "Done uninstall static package."
	} || {
		apt purge nvidia* libnvidia*
	}
}

[[ ${package} == "auto" ]] && {
	log-step "Install auto version form online repository..."
	apt update
	apt install nvidia-driver firmware-misc-nonfree
	exit 0
}

[[ ${package} ]] && {
	chmod +x ./${package}
	log-step "Install package ${package}..."
	./${package}
}

done=yes

# Mismatching nvidia kernel module loaded                                                                                                                                                                                                                                 │
# │                                                                                                                                                                                                                                                                         │
# │ The NVIDIA driver that is being installed (version 418.226.00) does not match the nvidia kernel module currently loaded (version 418.152.00).                                                                                                                           │
# │                                                                                                                                                                                                                                                                         │
# │ The X server, OpenGL, and GPGPU applications may not work properly.                                                                                                                                                                                                     │
# │                                                                                                                                                                                                                                                                         │
# │ The easiest way to fix this is to reboot the machine once the installation has finished. You can also stop the X server (usually by stopping
# the login manager, e.g. gdm3, sddm, or xdm), manually unload the module ("modprobe -r nvidia"), and restart the X server.
