#!/bin/bash

set -e

source $(which logshell)
source $(which checksystem)

[[ $(checkIfRootSession) == "no" ]] && {
    log-error "Need root permission to execute"
    exit 1
}

[[ $(checkIfCommandExist kubectl) ]] && {
    log-info "kubectl already installed"
} || {
    log-step "Install kubecrl"
    log-info "Install dependency, keyrings and source list"
    sudo apt-get update
    # apt-transport-https may be a dummy package; if so, you can skip that package
    sudo apt-get install -y apt-transport-https ca-certificates curl

    # keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    # add repo
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

    log-info "Install kubectl"
    sudo apt-get update
    sudo apt-get install -y kubectl

    [[ $? == 0 ]] && {
        log-step "Done install kubectl"
    }

    log-info "Vecify kube config"
    kubectl cluster-info
    [[ $? != 0 ]] && {
        Log-warning "Use 'kubectl cluster-info dump' command to check configuation of kubectl" 
    }
}

if checkIfFileHaveText "/usr/share/bash-completion/bash_completion" ~/.bashrc >/dev/null ;then 
    log-info "bash completion for kubectl is already installed"
else {
    kubectl completion bash >/usr/share/bash-completion/completions/kubectl

    bashrcConfig='
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
'
    echo "${bashrcConfig}" >>~/.bashrc
    log-step "bash completion for kubectl is installed"
}
fi






