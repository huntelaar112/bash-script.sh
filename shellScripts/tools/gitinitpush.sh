#!/bin/bash

set -e
#set +e # continue execute script in spite of command fail
#set -u
done=no
exitval=0

namescrpit=${0:2}

function help() {
	echo "Usage: ${namescrpit} path/to/project/folder git-remote-project
Description:
  - Create a git version of project in ~/git and push it to remote git server.
  - You need to create a remote git project before use this cmd.
  - After run, you have git project on ~/git folder.
"
	exit ${exitval}
}

remotelink=${2}
localproject=${1}

echo "Remote link: $remotelink"
echo "Local project: $localproject"

numberArgs="2"
[[ ${1} = "-h" || -z ${1} || "$#" -lt ${numberArgs} ]] && {
	echo "Missing arguments."
	help
}
source $(which logshell)

gitProjectDir=$(echo $remotelink | rev | cut -d "/" -f 1 | cut -d "." -f 2- | rev)

[[ ! -e ~/git ]] && {
	log-error "~/git folder is not exist."
	exit 1
}
[[ -e ~/git/$gitProjectDir ]] && {
	while true; do
		read -p "~/git/$gitProjectDir is already existed, do you wana to delete it? " yn
		case $yn in
		[Yy]*)
			rm -rf ~/git/$gitProjectDir
			break
			;;
		[Nn]*) exit 1 ;;
		*) echo "Please answer yes or no." ;;
		esac
	done
}

cd ~/git
git clone $remotelink
cd ${gitProjectDir}
cp -r $localproject ~/git/$gitProjectDir
git add .
git commit -m "init commit"
git push
