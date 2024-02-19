#!/bin/bash

chmod +x ./deploy-nginx.sh
source ./logshell

unknown_os() {
  echo "Unfortunately, your operating system distribution and version are not supported by this script."
  echo
  echo "You can override the OS detection by setting os= and dist= prior to running this script."
  echo "You can find a list of supported OSes and distributions on our website: https://packages.gitlab.com/docs#os_distro_version"
  echo
  echo "For example, to force Ubuntu Trusty: os=ubuntu dist=trusty ./script.sh"
  exit 1
}

detect_os() {
  if [[ (-z "${os}") && (-z "${dist}") ]]; then
    # some systems dont have lsb-release yet have the lsb_release binary and
    # vice-versa
    if [ -e /etc/lsb-release ]; then
      . /etc/lsb-release

      if [ "${ID}" = "raspbian" ]; then
        os=${ID}
        dist=$(cut --delimiter='.' -f1 /etc/debian_version)
      else
        os=${DISTRIB_ID}
        dist=${DISTRIB_CODENAME}

        if [ -z "$dist" ]; then
          dist=${DISTRIB_RELEASE}
        fi
      fi

    elif [ $(which lsb_release 2>/dev/null) ]; then
      dist=$(lsb_release -c | cut -f2)
      os=$(lsb_release -i | cut -f2 | awk '{ print tolower($1) }')

    elif [ -e /etc/debian_version ]; then
      # some Debians have jessie/sid in their /etc/debian_version
      # while others have '6.0.7'
      os=$(cat /etc/issue | head -1 | awk '{ print tolower($1) }')
      if grep -q '/' /etc/debian_version; then
        dist=$(cut --delimiter='/' -f1 /etc/debian_version)
      else
        dist=$(cut --delimiter='.' -f1 /etc/debian_version)
      fi

    else
      unknown_os
    fi
  fi

  if [ -z "$dist" ]; then
    unknown_os
  fi

  # remove whitespace from OS and dist name
  os="${os// /}"
  dist="${dist// /}"

  echo "Detected operating system as $os/$dist."
}

detect_version_id() {
  # detect version_id and round down float to integer
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    version_id=${VERSION_ID%%.*}
  elif [ -f /usr/lib/os-release ]; then
    . /usr/lib/os-release
    version_id=${VERSION_ID%%.*}
  else
    version_id="1"
  fi
}

curl_check() {
  log-step "Checking for curl..."
  if command -v curl >/dev/null; then
    echo "Detected curl."
  else
    echo "Installing curl..."
    apt install -q -y curl
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
    apt install -q -y wget
    if [ "$?" -ne "0" ]; then
      echo "Unable to install wget! Your base system has a problem; please check your default OS's package repositories because curl should work."
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
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

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

zip_check() {
  log-step "Checking for zip..."
  if command -v curl >/dev/null; then
    echo "Detected zip."
  else
    echo "Installing zip..."
    apt install -q -y zip
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
    apt install -q -y pigz
    if [ "$?" -ne "0" ]; then
      echo "Unable to install pigz! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
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

internet_check() {
  log-step "Checking internet connection..."
  timeout 10s curl ifconfig.me
  [[ $? -ne 0 ]] && {
    log-error "Can't not connect to Internet, check your internet connection."
    exit 1
  }
  echo " -- OK."
}

checkOsType() {
  cat /etc/os-release | grep "^ID=" | cut -d "=" -f 2
  [[ $? != 0  ]] && {
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


main() {
  curl_check
  internet_check
  log-step "Running apt update... "
  apt update &>/dev/null
  echo "done."

  wget_check
  zip_check
  pigz_check

  [[ $(checkOsType) == "ubuntu" ]] && {
  docker_check_ubuntu
    }

  [[ $(checkOsType) == "debian" ]] && {
  docker_check_debian
    }

  install_nginx
  disable-apt-autoupdate
  log-step "Done checking and setup env! You can now start install container apps."
}

main | tee -a /tmp/log-deploy.log
