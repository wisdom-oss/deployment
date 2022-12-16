#!/usr/bin/env bash
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

# Sudo Prepend if not started with sudo
sudo=''
branch=${BRANCH:=stable}
# Mapping of the blanks which will be replaced by random strings
password_blanks=("postgres-user" "postgres-pass" "authentik-secret-key" "authentik-admin-pass" "authentik-admin-api-token")
frontend_binding="frontend-binding"
authentik_binding="authentik-binding"

#==================================================================================================
# Checking for sudo privileges and prepending sudo if needed to every command
if [[ $(id -u) -ne 0 ]]; then
  sudo='sudo -E'
fi
echo -e "${orange}Using %{bold}$branch${normal}${orange}version of the project${normal}"
$sudo cp .env-template .env
echo -e "${lightgreen}Generating secrects with openssl${normal}"
for field in "${password_blanks[@]}"
do
    $sudo sed -i "s/<<$field>>/$(openssl rand -hex 16)/g" .env
done
echo -e "\n${green}✅ Generated secrets${nocolor}\n"

echo -e "\n${lightpurple}Authentik Setup${normal}"
echo -e "The platform uses authentik to authorize users in the frontend. Please select an apropriate"
echo -e "access method to authentik:"
echo -e "1) Access authentik on own domain"
echo -e "2) Access authentik on own port (recommended on internal deployments)"

while :
do
read -rp "Please select a installation method [2]: " option

if [[ $option == 1  ]]
then
  echo -e "Please enter the hostname which shall be used to access the authentik frontend"
  while :
  do
    echo -en "Binding for Authentik: "
    read -r hostname
    echo -en "You entered \"${hostname}\". Is this correct? [Y/n]: "
    read -r confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] || $confirm == "" ]]
    then
      $sudo sed -i "s/<<${authentik_binding}>>/$hostname/g" .env
      break
    fi
  done
  break
elif [[ $option == 2 || $option = "" ]]
then
  echo -e "The authentik container will be available on the port 8080"
  $sudo sed -i "s/<<${authentik_binding}>>/:8080/g" .env
  break
fi
done

echo -e "\n${lightpurple}Frontend${normal}"
echo -e "You have two installation options for the frontend:"
echo -e "1) Installing the system for intranet usage (Recommended for testing purposes) [${green}Standard${normal}]"
echo -e "2) Installing the system for internet usage (Recommended for deployment purposes, ⚠️ ${yellow}HTTPS Only${normal} ⚠️ )\n"

while :
do
read -rp "Please select a installation method [1]: " option

if [[ $option == 1 || $option = "" ]]
then
  $sudo sed -i "s/<<${frontend_binding}>>/:80/g" .env
  break
elif [[ $option == 2 ]]
then
  echo -e "Please enter the hostname unter which the dashboard shall be made available."
  echo -e "⚠️ ${yellow}The entered hostname needs to match the address used in the browser exactly${normal}\n"
  while :
  do
    echo -en "Binding for the frontend: "
    read -r hostname
    echo -en "You entered \"${hostname}\". Is this correct? [Y/n]: "
    read -r confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] || $confirm == "" ]]
    then
          $sudo sed -i "s/<<${frontend_binding}>>/${hostname}/g" .env
      break
    fi
  done
fi
done

echo -e "${lightcyan}Preparing Docker Compose Deployment${nocolor}"
$sudo docker network create wisdom
$sudo docker compose -f "docker-compose.$branch.yml" create

echo -e "${purple}Preparing the Kong API Gateway${nocolor}"
$sudo docker compose -f "docker-compose.$branch.yml" build api-gateway
$sudo docker compose -f "docker-compose.$branch.yml" start postgres
sleep 15
$sudo docker run --rm --network=wisdom --env-file .env wisdom-oss/api-gateway:latest kong migrations bootstrap -v
$sudo docker run --rm --network=wisdom --env-file .env wisdom-oss/api-gateway:latest kong migrations up -v
echo -e "${green}Starting WISdoM Platform${nocolor}"
$sudo docker compose -f "docker-compose.$branch.yml" build
$sudo docker compose -f "docker-compose.$branch.yml" up -d
