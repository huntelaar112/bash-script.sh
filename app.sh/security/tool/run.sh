#!/bin/bash

#set -e
set +e # continue execute script in spite of command fail
#set -u
done=no
exitval=0

namescrpit=${0:2}

function Wpscan() {
  URL_SCAN="${1}"
  echo "website:" "$URL_SCAN"
  domain=$(echo "$URL_SCAN" | sed 's|.*//\([^/]*\).*|\1|')
  docker run --rm \
    --mount type=bind,source="$(pwd)/${resultDir}/wpscan-report",target=/output \
    wpscanteam/wpscan:latest \
    -o /output/"$domain".txt \
    --url "${URL_SCAN}" \
    --api-token "${WPS_TOKEN}" \
    -e vp --random-user-agent \
    --plugins-detection mixed
  #    --http-auth "${HTTP_AUTH}"

  [[ $? ]] && {
    log-info "Resutl save to $(pwd)/${resultDir}/$domain.txt"
  }
}

function help() {
  echo "Usage: ${namescrpit} config.env -dwsc
  Note: This script need sudo permission to execute.
  Use:
    -d: use owasp/dependency-check
    -s: use sonar-scanner-cli
    -c: use scancode-toolkit
    -w: use wpscan
    "
  exit ${exitval}
}

configFile=${1}
numberArgs="1"
[[ ${1} = "-h" || -z ${1} || "$#" -lt ${numberArgs} ]] && {
  echo "Missing arguments."
  help
}
configPath=$(realpath $configFile)
source $(which logshell)
source ${configPath}
## for log-info, log-error, log-warning, log-run, log-debug, log-step

log-step "Pulling needed image..."
#docker pull owasp/dependency-check:latest
#docker pull sonarsource/sonar-scanner-cli:latest
#docker pull gianlucadb0/scancode-toolkit
#docker pull wpscanteam/wpscan:latest
resultDir="scan-results"
[[ ! -d ./${resultDir} ]] && {
  mkdir ./${resultDir}
}

option="${2}"
[[ -z ${2} ]] && {
  option="-dwsc"
}

[[ "$option" == *"d"* ]] && {
  log-step "Start running owasp/dependency-check..."
  #tempdir=$(mktemp -d)
  ./dependency-check.sh "${configPath}"
  [[ $? ]] && {
    log-info "Resutl save to $(pwd)/${resultDir}/dependency-check-report"
  }
}

[[ "$option" == *"s"* ]] && {
  log-step "Start running sonarsource/sonar-scanner-cli..."
  ./sonar-scanner.sh "${configPath}" | tee $(pwd)/${resultDir}/sonar-scanner-report.txt
  [[ $? ]] && {
    log-info "Result save to $(pwd)/scan-results/sonar-scanner-report.txt"
  }
}

[[ "$option" == *"c"* ]] && {
  log-step "Start running gianlucadb0/scancode-toolkit..."
  [[ ! -d $(pwd)/scan-results/license-report ]] && {
    mkdir $(pwd)/scan-results/license-report
  }
  touch $(pwd)/scan-results/license-report/scancode-report.txt
  docker run -it --rm -v "${YOUR_REPO}":/wd \
    --workdir=/wd gianlucadb0/scancode-toolkit \
    scancode -clpeui -n 4 --cyclonedx scancode-results-cyclonedx --spdx-tv scancode-results-spdx --json-pp scancode-results.json ./ | tee $(pwd)/scan-results/license-report/scancode-report.txt

  mv -f scancode* $(pwd)/scan-results/license-report
  [[ $? ]] && {
    log-info "Resutl save to $(pwd)/${resultDir}"
  }
}

[[ "$option" == *"w"* ]] && {

  log-step "Start running wpscanteam/wpscan..."
  [[ ! -d $(pwd)/scan-results/wpscan-report ]] && {
    mkdir $(pwd)/scan-results/wpscan-report
  }
  #  docker run --rm --mount type=bind,source=$(pwd)/${resultDir}/wpscan-report,target=/output wpscanteam/wpscan:latest \
  #    -o /output/wpscan-output.txt --url ${URL_SCAN} --api-token {WPS_TOKEN} -e vp --plugins-detection mixed --http-auth 'drill:drill@2021$'

  IFS=', ' read -r -a URL_ARRAY <<<"$URL_SCANs"

  # Print the elements of the array
  for url in "${URL_ARRAY[@]}"; do
    Wpscan "$url" &
  done
  wait
}

