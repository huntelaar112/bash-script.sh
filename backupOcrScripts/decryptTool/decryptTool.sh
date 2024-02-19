#!/bin/bash

set +e

done=no
exitval=0

namescrpit=${0:2}
listdatimages=$(mktemp)
interval=3600 # one hour
inpath=${1}
outpath=${2}
source $(which logshell)

function cleanup() {
	rm -f "${files}"
}
trap "cleanup" EXIT ERR
log-info "File save list iamge-files: $listdatimages"

function help() {
	echo "Usage: ${namescrpit} <input-encrypted-path> <output-decrypted-path>

Notes:
  - Need root permission to execute.
  - Install python3, pip3 and required python package"
	exit ${exitval}
}

numberArgs="2"
[[ ${1} = "-h" || -z ${1} || "$#" -lt ${numberArgs} ]] && {
	echo "Missing arguments."
	help
}

{
	while :; do
		log-step "Find all .dat image file in $inpath (Save to ${listdatimages})"
		find ${inpath} -name "*.dat" >${listdatimages}

		nimages=$(wc -l <"${listdatimages}")
		((nimages == 0)) && {
			log-info "There are no .dat image in directory ${inpath}"
			exit 0
		}

		((nimages > 0)) && {
			log-run "Start decrypt .dat image in directory: ${inpath}"

			while read line; do
				imagedir=$(dirname "${line}")
				imagename=$(basename "${line}")
				mkdir -p "${outpath}/${imagedir}"
				log-info "Decrypt ${line} to ${outpath}/${imagedir}/${imagename}.jpg"
				python3 /bin/toolDecrypt.py "${line}" "${outpath}/${imagedir}/${imagename}.jpg"
				[[ -e "${outpath}/${imagedir}/${imagename}.jpg" ]] && {
					log-step "Done, remove .dat file: "${line}""
					rm "${line}"
				} || {
					log-error "Fail to decrypt!"
				}
			done <"${listdatimages}"

			log-step "Done. Wait to next time check and decrypt .dat images (1 hour)"
		}
		sleep ${interval}
	done
} |& tee -a /tmp/decrypt-backup.log

done=yes
