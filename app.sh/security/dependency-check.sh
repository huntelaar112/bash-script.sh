#!/bin/bash

set -e
configpath="${1}"
source ${configpath}

#DC_VERSION="latest"
DC_VERSION="9.0.10"
DC_DIRECTORY="${HOME}/OWASP-Dependency-Check"
#DC_DIRECTORY=/tmp/OWASP-Dependency-Check
DC_PROJECT="dependency-check scan: $(pwd)"
DATA_DIRECTORY="$DC_DIRECTORY/data"
CACHE_DIRECTORY="$DC_DIRECTORY/data/cache"

if [ ! -d "$DATA_DIRECTORY" ]; then
    echo "Initially creating persistent directory: $DATA_DIRECTORY"
    mkdir -p "$DATA_DIRECTORY"
fi
if [ ! -d "$CACHE_DIRECTORY" ]; then
    echo "Initially creating persistent directory: $CACHE_DIRECTORY"
    mkdir -p "$CACHE_DIRECTORY"
fi

# Make sure we are using the latest version
docker pull owasp/dependency-check:$DC_VERSION

docker run --rm \
    -e user=root \
    -u 0:0 \
    --volume "${YOUR_REPO}":/src:z \
    --volume "${DATA_DIRECTORY}":/usr/share/dependency-check/data:z \
    --volume $(pwd)/scan-results/dependency-check-report:/report:z \
    mannk98/dependency-check:$DC_VERSION \
    --scan /src \
    --format "JSON" --format "CSV" --format "HTML" \
    --project "$DC_PROJECT" \
    --out /report \
    --enableExperimental --failOnCVSS 7

# Use suppression like this: (where /src == $pwd)
# --suppression "/src/security/dependency-check-suppression.xml"
#-e user=root \
#-u 0:0 \
