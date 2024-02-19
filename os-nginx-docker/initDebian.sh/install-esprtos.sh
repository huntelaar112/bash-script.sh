#!/bin/bash

sudo -s
apt-get install gcc git wget make libncurses-dev flex bison gperf python2 pip

mkdir -p ~/esp
cd ~/esp
#Dowload xtensa toolchain
curl -s -L https://dl.espressif.com/dl/xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-amd64.tar.gz -o
tar -xzf ~/esp/xtensa.tar.gz

echo "export PATH="$PATH:$HOME/esp/xtensa-lx106-elf/bin"" >> ~/.bashrc
echo "export PATH="$PATH:$HOME/.local/bin/"" >> ~/.bashrc
echo "export IDF_PATH=~/esp/ESP8266_RTOS_SDK" >> ~/.bashrc

source ~/.bashrc

#sudo usermod -a -G dialout $USER
#sudo chmod -R 777 /dev/ttyUSB0

# install libraries and api
git clone --recursive https://github.com/espressif/ESP8266_RTOS_SDK.git

# install requirement modules
pip install click pyserial future cryptography pyparsing pyelftools
pip install --force-reinstall -v "pyparsing==2.0.3"

# start hello world project
cp -r $IDF_PATH/examples/get-started/hello_world .
make menuconfig CONFIG_SDK_PYTHON=python3
# chagne defaut python to python3
# make flash
# make monitor