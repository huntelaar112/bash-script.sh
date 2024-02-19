#!/bin/bash

set -e
done=no
confpath="${1}"
EXITEVAL=""
imagename="AIX-01NX_L4T_32.6.1_20220414.tar.gz"
[[ $confpath = "-h" ]] && {
	echo "Script to recovery aix-01nx.
  Notes:
  Copy AIX image to same folder with this script.
  Run this script with sudo permission."
	exit 0
}

#source $confpath
source $(which logshell)

#[[ $userName && $Password && $ServerName ]] && {
#  echo "Apply download info."
#} || {
#  echo "Missing download info. Exit now"
#  exit 1
#}

log-info "Install dependency application..."
apt install libxml2-utils simg2img network-manager abootimg sshpass device-tree-compiler
[[ $? -ne 0 ]] && {
	log-erorr "Error happen when installing dependency, check apt install again."
	exit 1
}

echo "Download flashed Image..."
#wget ftp://${userName}:${Password}@${serverName}/AIX-01NX_L4T_32.6.1_20220414.tar.gz
#wget ftp://${userName}:${Password}@${serverName}/MD5_AIX-01NX_L4T_32.6.1_20220414

#If Files [File 1] and [File 1] are identical is displayed, the correctness is confirmed.
#checkDowload=$(diff -s <(md5sum AIX-01NX_L4T_32.6.1_20220414.tar.gz) <(cat MD5_AIX-01NX_L4T_32.6.1_20220414))
#checkDowload=$(echo $checkDowload | rev | cut -d ' ' -f 1 | rev)
#[[ $checkDowload == "identical" ]] && {
#  echo "Download success"
#} || {
#  echo "There are md5sum not match --> Just check download process."
#  exit 1
#}

[[ -e ./${imagename} ]] && {
	[[ -e ./Linux_for_Tegra/flash_jetson_nvme.sh ]] && {
		log-info "Flash image already unzip, next step."
	} || {
		log-info "Starting unzip ${imagename} ..."
		tar -xpf AIX-01NX_L4T_32.6.1_20220414.tar.gz
		log-info "Done unzip image."
	}
} || {
	log-error "Missing flash image, you need to download it first."
}

flashImage() {
	code=$(lsusb | grep "NVIDIA Corp." | cut -b 29-32)
	[[ $code == "7e19" ]] && {
		log-info "Start flashing process."
		cd Linux_for_Tegra && bash ./flash_jetson_nvme.sh
	}
	[[ $code != "7e19" ]] && {
		log-error "Jetson box not in Recovery mode. Hold the REC button, unplug and replug the power cord in 2 seconds."
		exit 1
	}
}

while true; do
	read -p "Do you put jetson xavier to recovery mode?" yn
	case $yn in
	[Yy]*)
		flashImage
		break
		;;
	[Nn]*) exit ;;
	*) echo "Please answer yes or no." ;;
	esac
done

echo "Done."
exit 0
