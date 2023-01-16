#!/usr/bin/env bash
#title        : update.sh
#description  : Update Script for WISoM OSS
#author       : Jan Eike Suchard (jan-eike.suchard@magenta.de)
#date         : 202220211
#version      : 0.1
#usage        : bash update.sh
#==================================================================================================
ROOT_DIRECTORY="/opt/wisdom-oss"
# colors
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

# Sudo Prepend if not started with sudo
sudo=''
branch=${BRANCH:=stable}

#==================================================================================================
# Checking for sudo privileges and prepending sudo if needed to every command
if [[ $(id -u) -ne 0 ]]; then
  sudo='sudo -E'
fi
# Allow the script to run unattended (for usage in cron scripts)
UNATTENDED=0
while getopts "yh:" OPTION; do
  case "$OPTION" in
    y)
      UNATTENDED=1
      ;;
    h)
      echo -e "Script usage: $(basename \$0) [-y] [-h]\nUse the -y flag to run the upgrade script unattended and to allow all changes" >&2
      exit 0
      ;;
    ?)
      echo -e "Script usage: $(basename \$0) [-y] [-h]" >&2
      exit 1
      ;;
  esac
done
echo -e "${lightcyan}Updater for the WISdoM OSS Project${nocolor}"

echo -e "${orange}This script will update all Docker Images and configuration files to the latest
version. This updater will try to keep the changes you may have made locally,
but in some cases this will not be possible. The updater will exit and you
will need to make the apropriate changes manually by running 'git' commands.${nocolor}"

if [ $UNATTENDED -eq 0 ]; then
  echo -en "${yellow}Do you whish to continue with the updates? (y/N): ${nocolor}"
  read -r confirmUpdaterExecution && [[ $confirmUpdaterExecution == [yY] || $confirmUpdaterExecution == [yY][eE][sS] ]] ||  exit 1
fi
clear

cd $ROOT_DIRECTORY || return

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
$sudo docker compose -f "docker-compose.$branch.yml" down
echo -e "\n${green}✅ Stopped all currently running containers${nocolor}\n"
echo -e "${lightcyan}1.2 Pulling the deployment Repo for new files${nocolor}"
$sudo git pull --force
echo -e "\n${green}✅ Pulled from the deployment repository${nocolor}\n"

# Now get the names of the new environment variables
readarry -t newEnvs < .env.new

for newEnv in "${newEnvs[@]}"
  do
    echo -e "${yellow}Generating new value for ${newEnv}"
    echo -e "${newEnv}=openssl rand -hex 16" | $sudo tee -a .env
done

echo -e "${cyan}2 Creating new Docker Images${nocolor}\n"
$sudo docker compose -f "docker-compose.$branch.yml" build
echo -e "\n${green}✅ Successfully created new docker images${nocolor}\n"

echo -e "${purple}Updating the Kong API Gateway Database${nocolor}"
$sudo docker compose -f "docker-compose.$branch.yml" start postgres > /dev/null
sleep 15
$sudo docker run --rm --network=wisdom --env-file .env wisdom-oss/api-gateway:latest kong migrations bootstrap -v
$sudo docker run --rm --network=wisdom --env-file .env wisdom-oss/api-gateway:latest kong migrations up -v

read -rp "Update finished. Shall the WISdoM Platform be started? [y/N]:" option


if [[ $option == "y" ]]; then
echo -e "${green}Starting WISdoM Platform${nocolor}"
$sudo docker compose -f "docker-compose.$branch.yml" --env-file .env up -d
else
echo -e "To start the WISdoM Platform run: docker compose -f \"docker-compose.$branch.yml\" --env-file .env up -d"
fi