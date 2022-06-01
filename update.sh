#!/usr/bin/env bash
#title        : update.sh
#description  : Update Script for WISoM OSS
#author       : Jan Eike Suchard (jan-eike.suchard@magenta.de)
#date         : 202220211
#version      : 0.1
#usage        : bash update.sh
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
# Mapping of passwords which shall be generated and in which file it may be needed
password_blanks=("gen-pass-rabbitmq" "gen-postgres-pass" "gen-redis-pass")
caddy_binding = "binding"
# Location of the docker-compose file relative to the current directory
compose_file_location="./docker-compose.yml"

# Sudo Prepend if not started with sudo
sudo=''

# ======================================== START OF SCRIPT ========================================

# Check if the current user is root or running with sudo
if [[ $(id -u) -ne 0 ]]; then
    sudo='sudo -E'
fi

echo -e "${lightcyan}Updater for the WISdoM OSS Project${nocolor}"

echo -e "${orange}This script will update all Docker Images and configuration files to the latest
version. This updater will try to keep the changes you may have made locally,
but in some cases this will not be possible. The updater will exit and you 
will need to make the apropriate changes manually by running 'git' commands.${nocolor}"

echo -en "${yellow}Do you whish to continue with the updates? (y/N): ${nocolor}"
read -r confirmUpdaterExecution && [[ $confirmUpdaterExecution == [yY] || $confirmUpdaterExecution == [yY][eE][sS] ]] ||  exit 1
clear

echo -e "${purple}Checking for a newer update script${nocolor}"
ORIGINAL_SUM=$(sha1sum update.sh)
echo -e "Original: ${ORIGINAL_SUM}"
$sudo git fetch origin
$sudo git checkout origin/main update.sh
NEW_SUM=$(sha1sum update.sh)
echo -e "New: ${NEW_SUM}"
if [[ ${ORIGINAL_SUM} != ${NEW_SUM} ]]; then
  echo "update.sh changed, please run this script again, exiting."
  exit 2
fi

echo -e "${lightcyan}1.1 Stopping all currently running containers${nocolor}"
$sudo docker compose down
echo -e "\n${green}✅ Stopped all currently running containers${nocolor}\n"


echo -e "${lightcyan}1.3 Pulling the deployment Repo for new files${nocolor}"
$sudo git reset --hard HEAD
$sudo git pull --force
echo -e "\n${green}✅ Pulled from the deployment repository${nocolor}\n"

# Create new passwords for possibly newly created services where needed
for password_field in "${password_blanks[@]}"
  do
    if [[ -f "./.tokens/.$password_field" ]]; then
      echo -e "Found existing password for: ${password_field}"
      find . -type f -exec $sudo sed -i "s,<<$password_field>>,$(cat ./.tokens/.$password_field),g" {} \;
    else
      openssl rand -hex 16 | $sudo tee "./.tokens/.$password_field" > /dev/null
      find . -type f -exec $sudo sed -i "s,<<$password_field>>,$(cat ./.tokens/.$password_field),g" {} \;
    fi
done

if [[ -f "./.tokens/.caddy-binding" ]]; then
  echo -e "Found existing Caddy Binding: $(cat ./.tokens/.caddy-binding)"
  find . -type f -exec $sudo sed -i "s,<<binding>>,$(cat ./.tokens/.caddy-binding),g" {} \;
else
  echo -e "\n${lightpurple}HTTP Server Setup${normal}"
  echo -e "You have two installation options for the system:"
  echo -e "1) Installing the system for intranet usage (Recommended for testing purposes) [${green}Standard${normal}]"
  echo -e "2) Installing the system for internet usage (Recommended for deployment purposes, ⚠️ ${yellow}HTTPS Only${normal} ⚠️ )\n"

  while : ; do
    read -rp "Please select a installation method [1]: " option

    if [[ $option == 1 || $option = "" ]]
    then
      echo ":80" | $sudo tee "./.tokens/.caddy-binding"
      find . -type f -exec $sudo sed -i "s,<<$${caddy_binding}>>,$(cat ./.tokens/.caddy-binding),g" {} \;
      break
    elif [[ $option == 2 ]]; then
      echo -e "Please enter the hostname unter which the dashboard shall be made available."
      echo -e "⚠️ ${yellow}The entered hostname needs to match the address used in the browser exactly${normal}\n"
      while : ; do
        echo -en "Hostname: "
        read -r hostname
        echo -en "You entered \"${hostname}\". Is this correct? [Y/n]: "
        read -r confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] || $confirm == "" ]] ; then
          echo $hostname | $sudo tee "./.tokens/.caddy-binding" 
          find . -type f -exec $sudo sed -i "s,<<$${caddy_binding}>>,$(cat ./.tokens/.caddy-binding),g" {} \;
          break
        fi
      done
    fi
  done
fi


echo -e "${cyan}2 Creating new Docker Images${nocolor}\n"
$sudo docker compose build --no-cache
echo -e "\n${green}✅ Successfully created new docker images${nocolor}\n"

echo -e "${cyan}3 Restarting the containers${nocolor}\n"
$sudo docker compose up -d
