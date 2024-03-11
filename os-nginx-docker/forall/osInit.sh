#!/bin/bash
#set -e
chmod +x ./deploy-nginx.sh
source $(which logshell)
sourec $(which checksystem)

[[ $? != 0 ]] && {
  echo "ERROR: Running install bash script in bash-script.sh before"
  exit 1
}

internet_check() {
  log-step "Checking internet connection..."
  timeout 10s curl ifconfig.me
  [[ $? -ne 0 ]] && {
    log-error "Can't not connect to Internet, check your internet connection."
    return 1
  }
  echo " -- OK."
}

curl_check() {
  log-step "Checking for curl..."
  if command -v curl >/dev/null; then
    echo "Detected curl."
  else
    echo "Installing curl..."
    apt-install curl
    if [ "$?" -ne "0" ]; then
      echo "Unable to install curl! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
  fi
}

wget_check() {
  log-step "Checking for wget..."
  if command -v curl >/dev/null; then
    echo "Detected wget."
  else
    echo "Installing wget..."
    apt-install wget
    if [ "$?" -ne "0" ]; then
      echo "Unable to install wget! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
  fi
}

zip_check() {
  log-step "Checking for zip..."
  if command -v curl >/dev/null; then
    echo "Detected zip."
  else
    echo "Installing zip..."
    apt-install zip
    if [ "$?" -ne "0" ]; then
      echo "Unable to install zip! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
  fi
}

pigz_check() {
  log-step "Checking for pigz..."
  if command -v curl >/dev/null; then
    echo "Detected pigz."
  else
    echo "Installing pigz..."
    apt-install pigz
    if [ "$?" -ne "0" ]; then
      echo "Unable to install pigz! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
  fi
}

resolvconf_check() {
  log-step "Checking for resolvconf..."
  if command -v curl >/dev/null; then
    echo "Detected resolvconf."
  else
    echo "Installing resolvconf..."
    apt-install resolvconf
    if [ "$?" -ne "0" ]; then
      echo "Unable to install resolvconf! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
  fi
}

docker_check_debian() {
  log-step "Checking for docker..."
  if command -v docker >/dev/null; then
    {
      echo "Detected docker."
      #source ./dsutils
    }
  else
    echo "Installing docker dependency..."
    apt-get install -y -q ca-certificates curl gnupg
    echo "Add Docker’s official GPG key..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "Setup repository..."
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    echo "Install docker packages..."
    sudo apt-get update
    apt install -y -q docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    log-info "Starting and test docker..."
    systemctl start docker
    systemctl enable docker
    docker run hello-world
    if [ "$?" -ne "0" ]; then
      echo "Unable to install docker! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
    echo "Done."
  fi
}

docker_check_ubuntu() {
  log-step "Checking for docker..."
  if command -v docker >/dev/null; then
    {
      echo "Detected docker."
      #source ./dsutils
    }
  else
    echo "Installing docker dependency..."
    apt-get install -y -q ca-certificates curl gnupg
    echo "Add Docker’s official GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo "Setup repository..."
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    echo "Install docker packages..."
    sudo apt-get update
    apt install -y -q docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    log-info "Starting and test docker..."
    systemctl start docker
    systemctl enable docker
    docker run hello-world
    if [ "$?" -ne "0" ]; then
      echo "Unable to install docker! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
    echo "Done."
  fi
}

docker_check_cenred() {
  log-step "Checking for docker..."
  if command -v docker >/dev/null; then
    {
      echo "Detected docker."
      #source ./dsutils
    }
  else
    echo "Installing docker..."
    yum install -y -q yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum check-update >/dev/null
    log-info "Uninstall podman and buildah packages."
    sudo yum -y -q remove podman buildah
    echo "Install docker packages..."
    yum install -y -q docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    log-info "Starting and test docker..."
    systemctl start docker
    systemctl enable docker
    docker run hello-world
    if [ "$?" -ne "0" ]; then
      echo "Unable to install docker! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
    echo "Done."
  fi
}

install_nginx() {
  log-step "Install nginx (for load balancer, domain config, ssl config)..."
  echo "Create docker network..."
  docker network create -o "com.docker.network.bridge.name"="ocrnetwork" --subnet="172.172.0.0/24" ocrnetwork
  echo "Deploy nginxdemos/hello for test."
  docker run --name hello --hostname hello --network ocrnetwork -idt nginxdemos/hello
  echo "Deploy nginx container..."
  chmod +x ./deploy-nginx.sh
  bash ./deploy-nginx.sh
  [[ "$?" -ne 0 ]] && {
    log-error "Fail to install nginxgen container."
    exit 1
  }
  sleep 7s
  [[ ! -d "/mnt/containerdata/nginxgen/etc_nginxgen_watchroot" ]] && {
    sleep 10s
  } || {
    cp ./nginxgenconfig.toml /mnt/containerdata/nginxgen/etc_nginxgen_watchroot/
    cp ./env.jenv /mnt/containerdata/nginxgen/etc_nginxgen_watchroot/
  }
  docker restart nginxgen
}

checkOsType() {
  cat /etc/os-release | grep "^ID=" | cut -d "=" -f 2
  [[ $? != 0 ]] && {
    return 1
  }
}

disable-apt-autoupdate() {
  local content="
APT::Periodic::Update-Package-Lists \"0\";
APT::Periodic::Unattended-Upgrade \"0\";"

  echo "${content}" >/etc/apt/apt.conf.d/20auto-upgrades
  [[ $? == 0 ]] && {
    systemctl restart apt-daily.timer
    return 0
  } || return 1
  echo "apt auto update is disabled"
}

configNetwork() {
  ip=${1}
  netmark=${2}
  gateway=${3}
  name=${4}

  etc_network_interfaces="
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

allow-hotplug ${name}
iface eno1 inet static
    address ${ip}
    netmask ${netmark}
    gateway ${gateway}
    dns-nameservers 1.1.1.1 8.8.8.8
"
  [[ $(checkIfFileHaveText allow-hotplug "/etc/network/interfaces") == "no" ]] && {
    echo "${etc_network_interfaces}" >/etc/network/interfaces
  }

  ifdown "${name}"
  ifup "${name}"
  sleep 3
}

main() {
  curl_check
  internet_check
  [[ $? != 0 ]] && {
    iface=eno1
    configNetwork "10.6.203.241" "255.255.252.0" "10.6.200.1" ${iface}
    internet_check
    [[ $? != 0 ]] && exit 1
  }

  log-step "Intall utiliies..."
  apt-install netcat-openbsd iotop htop flameshot git openssh-server iproute nano
  resolvconf_check
  log-step "Running apt update... "
  apt update &>/dev/null
  echo "done."

  wget_check
  zip_check
  pigz_check

  [[ $(checkOsType) == "ubuntu" ]] && {
    docker_check_ubuntu
    disable-apt-autoupdate
  }

  [[ $(checkOsType) == "debian" ]] && {
    docker_check_debian
    disable-apt-autoupdate
  }

  [[ $(checkOsType) == "centos" || $(checkOsType) == "redhat" ]] && {
    docker_check_cenred
  }

  [[ $(checkIfCommandExist docker) == "no" ]] && {
    curl -fsSL https://get.docker.com -o install-docker.sh
    bash install-docker.sh
    systemctl start docker
    systemctl enable docker
    docker run hello-world
    if [ "$?" -ne "0" ]; then
      echo "Unable to install docker! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
  }

  install_nginx
  log-step "Done checking and setup env! You can now start install container apps. (check setup log at /tmp/log-deploy.log)"
}

main | tee -a /tmp/log-deploy.log
