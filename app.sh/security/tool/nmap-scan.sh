#!/bin/bash

set -e

[[ -z $(command -v  xsltproc) ]] && {
    apt install xsltproc
}

domain=${1}

git clone https://github.com/scipag/vulscan.git && chmod 774 vulscan/update.sh && ./vulscan/update.sh
nmap -sV --script=vulscan/vulscan.nse -oX "${domain}".xml "${domain}"

xsltproc "${domain}".xml -o "${domain}".html