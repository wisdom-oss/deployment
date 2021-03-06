#!/usr/bin/env bash
#title        : easy-install.sh
#description  : Easy installation script for the wisdom oss project. This script will automate the
#               most steps for running the wisdom dashboard in a docker environment.
#author       : Jan Eike Suchard (jan-eike.suchard@magenta.de)
#date         : 20211129
#version      : 0.1
#usage        : bash easy-install.sh
#==================================================================================================

#------------
# VARIABLES
#------------


# Colors for colored output to the console
nocolor='\033[0m'
red='\033[0;31m'
green='\033[0;32m'
orange='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
lightgray='\033[0;37m'
darkgray='\033[1;30m'
lightred='\033[1;31m'
lightgreen='\033[1;32m'
yellow='\033[1;33m'
lightblue='\033[1;34m'
lightpurple='\033[1;35m'
lightcyan='\033[1;36m'
white='\033[1;37m'
bold=$(tput bold)
normal=$(tput sgr0)

ROOT_DIRECTORY="/opt/wisdom-oss"
BRANCH="main"

# Mapping of passwords which shall be generated and in which file it may be needed
password_blanks=("gen-pass-rabbitmq" "gen-postgres-pass" "gen-redis-pass")
caddy_binding="binding"
# Location of the docker-compose file relative to the current directory
compose_file_location="./docker-compose.yml"

# Sudo Prepend if not started with sudo
sudo=''

#==================================================================================================
# Checking for sudo privileges and prepending sudo if needed to every command
if [[ $(id -u) -ne 0 ]]; then
  sudo='sudo -E'
fi

echo -e "${lightcyan}Welcome to the WISdoM OSS Project${nocolor}

${purple}This script is intended to be used on a fresh install of either Ubuntu 20.04
LTS, Ubuntu 21.04 or Ubuntu 21.10 [all 64bit]${nocolor}

${yellow}WARNING
If this is not a fresh install of either of the named operating systems you may
continue running this script, but keep in mind that some of the commands may
not work or will brick your current installation requiring a complete
re-installation of your operating system${nocolor}"

echo -en "${orange}Do you wish to continue with the installation and setup? (y/N): ${nocolor}"
read -r confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] ||  exit 1
clear

echo -e "${lightcyan}1.1 Updating the package index${nocolor}\n"
$sudo apt-get -q update
echo -e "\n${green}??? Updated the package sources${nocolor}\n"

echo -e "${lightcyan}1.2 Installing possible package updates${nocolor}\n"
$sudo apt-get dist-upgrade -q -y
echo -e "\n${green}??? Installed the available package updates${nocolor}\n"

echo -e "${lightcyan}1.3 Removing all unused packages${nocolor}\n"
$sudo apt-get autoremove -q -y
echo -e "\n${green}??? Installed the available package updates${nocolor}\n"

echo -e "${cyan}2.1 Removing outdated Docker packages${nocolor}\n"
$sudo apt-get -q -y remove docker docker-engine docker.io containerd runc 2>/dev/null
echo -e "\n${green}??? Removed outdated Docker packages${nocolor}\n"

echo -e "${cyan}2.2 Installing the dependencies for the Docker Engine${nocolor}\n"
$sudo apt-get -q -y install \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  unzip \
  git
echo -e "\n${green}??? Installed dependencies for Docker Engine${nocolor}\n"

echo -e "${cyan}2.3 Adding the signing key of the docker engine repository${nocolor}\n"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo -e "\n${green}??? Added the signing key successfully${nocolor}\n"

echo -e "${cyan}2.3 Adding docker engine repository to the apt sources${nocolor}\n"
echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
 https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | $sudo tee /etc/apt/sources.list.d/docker.list
echo -e "\n${green}??? Added the signing key successfully${nocolor}\n"

echo -e "${cyan}2.4 Updating the package index${nocolor}\n"
$sudo apt-get -q update
echo -e "\n${green}??? Updated the package sources${nocolor}\n"

echo -e "${cyan}2.5 Installing the Docker Engine and the Docker CLI${nocolor}\n"
$sudo apt-get -q -y install docker-ce docker-ce-cli containerd.io
echo -e "\n${green}??? Installed the Docker Engine and the Docker CLI${nocolor}\n"

echo -e "${cyan}2.6 Installing Docker Compose (v2)${nocolor}\n"
$sudo mkdir -p /usr/local/lib/docker/cli-plugins
$sudo curl -SL https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
$sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
echo -e "\n${green}??? Installed Docker Compose${nocolor}\n"

echo -e "${cyan}2.7 Activating BuildKit for Docker${normal}"
echo '{ "features": { "buildkit": true } }' | $sudo tee /etc/docker/daemon.json
$sudo service docker restart

echo -e "${red}LICENSE INFORMATION${normal}"
echo -e "The software deployed with this file currently has a proprietary license."
echo -en "${orange}Do you wish to continue with the deployment? (y/N): ${nocolor}"
read -r confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] ||  exit 1

echo -e "${lightblue}Cloning files for WISdoM OSS Version${normal}"
$sudo mkdir -p $ROOT_DIRECTORY
cd $ROOT_DIRECTORY || exit 1
$sudo git clone https://github.com/wisdom-oss/deployment.git .

echo -e "${lightgreen}Generating passwords with openssl${normal}"
$sudo mkdir -p ./.tokens
for password_field in "${password_blanks[@]}"
do
  openssl rand -hex 16 | $sudo tee "./.tokens/.$password_field" > /dev/null
  find . -type f -exec $sudo sed -i "s,<<$password_field>>,$(cat ./.tokens/.$password_field),g" {} \;
done
echo -e "\n${green}??? Generated passwords${nocolor}\n"

echo -e "\n${lightpurple}HTTP Server Setup${normal}"
echo -e "You have two installation options for the system:"
echo -e "1) Installing the system for intranet usage (Recommended for testing purposes) [${green}Standard${normal}]"
echo -e "2) Installing the system for internet usage (Recommended for deployment purposes, ?????? ${yellow}HTTPS Only${normal} ?????? )\n"

while :
do
read -rp "Please select a installation method [1]: " option

if [[ $option == 1 || $option = "" ]]
then
  echo ":80" | $sudo tee "./.tokens/.caddy-binding"
  find . -type f -exec $sudo sed -i "s,<<${caddy_binding}>>,$(cat ./.tokens/.caddy-binding),g" {} \;
  break
elif [[ $option == 2 ]]
then
  echo -e "Please enter the hostname unter which the dashboard shall be made available."
  echo -e "?????? ${yellow}The entered hostname needs to match the address used in the browser exactly${normal}\n"
  while :
  do
    echo -en "Hostname: "
    read -r hostname
    echo -en "You entered \"${hostname}\". Is this correct? [Y/n]: "
    read -r confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] || $confirm == "" ]]
    then
      echo $hostname | $sudo tee "./.tokens/.caddy-binding" 
      find . -type f -exec $sudo sed -i "s,<<${caddy_binding}>>,$(cat ./.tokens/.caddy-binding),g" {} \;
      break
    fi
  done
fi
done

echo -e "\n${green}??? Ready for startup${nocolor}\n"
echo -en "${orange}Do you wish start the containers? (Y/n): ${nocolor}"
read -r confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] || $confirm == "" ]]
then
  echo -e "\n${lightblue}Building the some of the containers${nocolor}\n"
  $sudo docker compose build --no-cache
  echo -e "\n${lightblue}Starting the the containers${nocolor}\n"
  $sudo docker compose up -d || echo -e "\n${red}Error while staring the containers${nocolor}\n" && exit 1
  sleep 10 && $sudo docker compose stop api-gateway && sleep 15 && docker compose start api-gateway
  echo -e "\n${green}??? Started the containers${nocolor}\n"
  exit 0
else
  echo -e "Please execute the following command to spin up the containers later:\n"
  echo -e "sudo docker compose -f $(pwd)/docker-compose.yml up -d"
  exit 0
fi

