#!/bin/bash

## PAGE DOWNLOAD RASPBERRY IMAGE
#https://downloads.raspberrypi.org/raspios_arm64/images/

set -e
#set -u
done=no
exitval=0

namescrpit=${0:2}

function help() {
	echo "Usage: ${namescrpit} imageName /dev/sdX setup.env
  Note:
    - This script need sudo permission to execute.
    - piVersion: pi4/pi3/pi2/piz/piz2.

  example setup.env:
    piVersion="pi4"
    user="pi"
    password="pi@123"
    wifi_name="your_wifi_name"
    wifi_pass="your_wifi_pass"
    staticIP="192.168.1.200"
    ntpServer="192.168.6.1"
    "
	exit ${exitval}
}

imageName=${1}
blockDevive=${2}
envFile=${3}

## for log-info, log-error, log-warning, log-run, log-debug, log-step
source $(which logshell)
log-info "Done load env file: ${envFile}."

[[ ! -e ${imageName} ]] && {
	log-error "Missing input argument"
  help
}

[[ ! -e "${blockDevive}" ]] && {
  log-error "Block device isn't exist."
  help
}

[[ ! -f "${envFile}" ]] && {
  log-error "Env isn't exist."
  help
}

source ${envFile}

log-step "Start flashing image."
dd if=${imageName} of=${blockDevive} bs=4M status=progress && sync
log-step "Done flashing image."

# disable mounted partition before all
fileMounted=$(df -h | grep "${blockDevive}[1-9]" | cut -d "%" -f 2)
df -h | grep "${blockDevive}[1-9]" | cut -d "%" -f 2 >/tmp/mountedFile.txt

[[ ! -z $fileMounted ]] && {
	log-info "Disable mounted partitions before remount."
	while read line; do
		umount $line
	done </tmp/mountedFile.txt
}

log-step "Mount boot partition to folder /media/${USER}/boot_pi && Mount rootfs partition to folder /media/${USER}/rootfs_pi"
mkdir -p "/media/${USER}/boot_pi"
mkdir -p "/media/${USER}/rootfs_pi"
mount "${blockDevive}1" "/media/${USER}/boot_pi"
mount "${blockDevive}2" "/media/${USER}/rootfs_pi"

rootfs="/media/${USER}/rootfs_pi"
boot="/media/${USER}/boot_pi"

encrpytPass=$(openssl passwd -6 ${password})
echo "${user}:${encrpytPass}" >"${boot}/userconf.txt"
[[ $? == "0" ]] && log-info "Config user(ssh)."

#704 is VN ISO_3166-1
wificonfig="ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=VN

network={
ssid=\"${wifi_name}\"
psk=\"${wifi_pass}\"
scan_ssid=1
key_mgmt=WPA-PSK
}"

echo "${wificonfig}" >"${boot}/wpa_supplicant.conf"
[[ $? == "0" ]] && log-info "Config wifi."

touch "${boot}/ssh"
[[ $? == "0" ]] && log-info "Enable ssh."

log-info "Config NTP server: ${ntpServer}"
### config ntp
ntpsetup="NTP=
FallbackNTP=${ntpServer}"

[[ ! -z $ntpServer ]] && {
	echo "${ntpsetup}" >>"${rootfs}/etc/systemd/timesyncd.conf"
	#systemctl restart systemd-timesyncd.service
}

## config static IP
netInterface="eth0"
[[ ${piVersion} == "piz" || ${piVersion} == "piz2" ]] && {
	netInterface="wlan0"
}
log-info "Config static IP ${netInterface}"
#piRevision=$(cat /proc/cpuinfo | grep "Revision" | cut -d ":" -f 2)
#piModel=$(cat /proc/cpuinfo | grep "Model" | cut -d ":" -f 2)
#[[ $piModel == "Raspberry Pi Zero W Rev 1.1" ]] && {
#  netInterface="wlan0"
#}
staticIpConfig="interface ${netInterface}

static domain_name_servers=1.1.1.1
static ip_address=${staticIP}
static routers=${staticIP:0:7}.1.1"

[[ ! -z ${staticIP} ]] && {
	cp "${rootfs}/etc/dhcpcd.conf" "${rootfs}/etc/dhcpcd.conf.bak"
	printf '%s\n' "${staticIpConfig}" >>"${rootfs}/etc/dhcpcd.conf"
}

log-info "Umount SD card."
umount "/media/${USER}/boot_pi"
umount "/media/${USER}/rootfs_pi"
rm -rf "/media/${USER}/boot_pi" "/media/${USER}/rootfs_pi"
rm -rf "/media/${USER}/boot_pi" "/media/${USER}/boot_pi"

udisksctl power-off -b ${blockDevive}
log-step "Done setup SD card, now it's ready to plug to your Raspberry Pi"
done=yes
