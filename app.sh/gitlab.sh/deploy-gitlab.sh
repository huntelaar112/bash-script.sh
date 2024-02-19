#!/bin/bash

set -e
done=no
exitval=0

namescrpit=${0:2}

function help() {
  echo "Usage: ${namescrpit} gitlab.env
  Note: This script need sudo permission to execute."
  exit ${exitval}
}
#echo $dockerNetwork
[[ -z ${1} || ${1} = "-h" ]] && {
  help
}

source $(which logshell)
source $(which dsutils)

[[ $(docker-network-is-exist ocrnetwork) ]] || {
  docker-network-create ocrnetwork 172.172.0.0/16
} 

source "${1}"

[[ -z ${gitlab_domain} ]] && {
  gitlab_domain="localhost"
}

sudo docker run --detach \
  --hostname "${gitlab_domain}" \
  --publish 4443:443 --publish 7080:80 --publish 234:22 \
  --name "${name}" --hostname "${name}" \
  --restart always -e TZ=Asia/Ho_Chi_Minh \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m "${image}"

#  docker exec -it "${name}" bash
#  nano /etc/gitlab/gitlab.rb

# Disable the bundled Omnibus provided PostgreSQL
gitlabPsqlConfig="\
# Disable the built-in Postgres
postgresql['enable'] = false\n\
# PostgreSQL connection details\n\
gitlab_rails['db_adapter'] = 'postgresql'\n\
gitlab_rails['db_encoding'] = 'utf8'\n\
gitlab_rails['db_port'] = 5432 \n\
gitlab_rails['db_host'] = '${db_address}' # IP/hostname of database server\n\
gitlab_rails['db_username'] = '${db_password}'
gitlab_rails['db_password'] = '${db_user}'"

#gitlabPsqlConfigParser=$(echo -e "${gitlabPsqlConfig}")

[[ "${use_psql}" == "true" ]] && {
  sleep 5
  docker exec "${name}" bash -c "echo -e \"${gitlabPsqlConfig}\" | tee -a /etc/gitlab/gitlab.rb" 
  [[ $? == 0 ]] && {
    log-step "Done setup Psql."
  } || log-error "Fail to setup Psql for gitlab-ce"

  docker exec "${name}" bash -c "gitlab-ctl reconfigure && gitlab-ctl restart"
}

docker logs -f "${name}"
#sudo gitlab-ctl reconfigure
#sudo gitlab-ctl restart
