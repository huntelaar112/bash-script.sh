#!/bin/bash

#set -e
#set +e # continue execute script in spite of command fail
#set -u
done=no
exitval=0

namescrpit=${0:2}

function help() {
	echo "Usage: ${namescrpit} /git/repo/directory
  Result file: allRepoInfo.csv & allSecretDetectedInfo.csv"
	exit ${exitval}
}

numberArgs="1"
[[ ${1} = "-h" || -z ${1} || "$#" -lt ${numberArgs} ]] && {
	echo "Missing arguments."
	help
}

allrepoinfo="allRepoInfo.csv"
allsecretleak="allSecretDetectedInfo.csv"
repoDir=${1}

## find list normal repo and bare repo
find ${repoDir} -name ".git" -type d -prune >/tmp/listRepo.txt
find ${repoDir} -type f -name "HEAD" | find ${repoDir} -type f -name "config" | find ${repoDir} -type f -name "description" | sed -r 's|/[^/]+$||' | sort | uniq >/tmp/findBareRepo.txt
while IFS="" read -r p || [ -n "$p" ]; do
	is_bare=$(git -C "$p" rev-parse --is-bare-repository 2>/dev/null)
	[[ $is_bare == true ]] && {
		echo "$p" >>/tmp/listRepo.txt
	}
done </tmp/findBareRepo.txt

## get all repos info to csv file. (name + size)
[[ -e ./${allrepoinfo} ]] && {
	rm ./${allrepoinfo}
	touch ${allrepoinfo}
	echo "Repo Name; Size(bytes)" >./${allrepoinfo}
}
while IFS="" read -r p || [ -n "$p" ]; do
	printf '%s;' "$p" >>./${allrepoinfo}
	du -sh $p | cut -c 1-4 >>./${allrepoinfo}
done </tmp/listRepo.txt

## get all secret info to csv file.
[[ -e ./${allsecretleak} ]] && {
	rm ./${allsecretleak}
	touch ${allsecretleak}
	echo "Description,StartLine,EndLine,File,SymlinkFile,Commit,Author,Email,Date-Modify,RuleID" >./${allsecretleak}
}
while IFS="" read -r p || [ -n "$p" ]; do
	printf 'Scan leaks in %s...' "$p"
	gitleaks detect --source ${p} -r /tmp/templeaks.json -f json
	content=$(cat /tmp/templeaks.json)
	[[ -s /tmp/templeaks.json && ${content} != "[]" ]] && {
		### convert json to csv (each git repo)
		printf 'RepoName: %s\n' "$p" >>./${allsecretleak}
		#sed 1d /tmp/tempinfo.csv >>./${allsecretleak}
		#csvvalue=$(jq -r '.[] | [.Description, .StartLine, .EndLine, .Match, .Secret, .File, .SymlinkFile, .Commit, .Author, .Email, .Date, .RuleID]\n | @csv' /tmp/templeaks.json)
		cat /tmp/templeaks.json | jq -r '.[] | "\(.Description), \(.StartLine), \(.EndLine), \(.File), \(.SymlinkFile), \(.Commit), \(.Author), \(.Email), \(.Date), \(.RuleID)"' >>./${allsecretleak}
		printf '\n' >>./${allsecretleak}
	}
done </tmp/listRepo.txt
printf "Date scan: " >>./${allsecretleak}
date >>./${allsecretleak}
done=yes
