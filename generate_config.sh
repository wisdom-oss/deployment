#!/usr/bin/env bash
set -o pipefail

for bin in openssl curl docker git awk sha1sum; do
  if [[ -z $(which ${bin}) ]]; then echo "Cannot find ${bin}, exiting..."; exit 1; fi
done

if [ -f wisdom.conf ]; then
  read -r -p "A config file exists and will be overwritten, are you sure you want to continue? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv wisdom.conf wisdom.conf_backup
      chmod 600 wisdom.conf_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi

echo "Press enter to confirm the detected value '[value]' where applicable or enter a custom value."
while [ -z "${CADDY_FRONTEND_BINDING}" ]; do
  read -p "Binding for the frontend (UI/API): " -e CADDY_FRONTEND_BINDING
done

while [ -z "${CADDY_AUTHENTIK_BINDING}" ]; do
  read -p "Binding for the authorization server: " -e CADDY_AUTHENTIK_BINDING
done

if [ -a /etc/timezone ]; then
  DETECTED_TZ=$(cat /etc/timezone)
elif [ -a /etc/localtime ]; then
  DETECTED_TZ=$(readlink /etc/localtime|sed -n 's|^.*zoneinfo/||p')
fi

while [ -z "${WISDOM_TZ}" ]; do
  if [ -z "${DETECTED_TZ}" ]; then
    read -p "Timezone: " -e WISDOM_TZ
  else
    read -p "Timezone [${DETECTED_TZ}]: " -e WISDOM_TZ
    [ -z "${WISDOM_TZ}" ] && WISDOM_TZ=${DETECTED_TZ}
  fi
done

echo "Which branch of WISdoM serivces do you want to use?"
echo ""
echo "Available Branches:"
echo "- stable branch (production-ready updates) | less features [1]"
echo "- main branch (stable updates) | default, recommended [2]"
echo "- dev branch (unstable updates, testing) | not-production ready [3]"
sleep 1

while [ -z "${SERVICE_BRANCH}" ]; do
  read -r -p  "Choose the Branch with it´s number [1/2/3] " branch
  case $branch in
    [3])
      SERVICE_BRANCH="dev"
      ;;
    [1])
      SERVICE_BRANCH="stable"
      ;;
    *)
      SERVICE_BRANCH="main"
    ;;
  esac
done

echo "Which branch of the WISdoM frontend do you want to use?"
echo ""
echo "Available Branches:"
echo "- stable branch (production-ready updates) | less features [1]"
echo "- main branch (stable updates) | default, recommended [2]"
sleep 1

while [ -z "${FRONTEND_BRANCH}" ]; do
  read -r -p  "Choose the Branch with it´s number [1/2] " branch
  case $branch in
    [1])
      FRONTEND_BRANCH="stable"
      ;;
    *)
      FRONTEND_BRANCH="main"
    ;;
  esac
done

AMQP_PASS=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)
PG_PASS=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)
AUTHENTIK_SECRET_KEY=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)

mkdir -p .secrets
echo -e "${PG_PASS}" > ./.secrets/.pgpass
echo -e "${AMQP_PASS}" > ./.secrets/.amqppass
echo -e "${AUTHENTIK_SECRET_KEY}" > ./.secrets/.authentik-secret-key

cat << EOF > wisdom.conf
#====== WISdoM Platform Configuraion ======
# ------------------------------
# Caddy Configuration (Web UIs)
# ------------------------------
# Due to the fact that this platform contains a inbuilt authentication solution
# and Caddy is able automatically request SSL certificates it needs to know
# what the addresses for the two services shall be used.

# CADDY_FRONTEND_BINDING
# Required: yes
#
# This setting sets the binding used to access the fronted and api. Only giving
# a port like ":80" is allowed and will bind port 80 and disable the automatic
# HTTPS deployment
CADDY_FRONTEND_BINDING="${CADDY_FRONTEND_BINDING}"

# CADDY_AUTHENTIK_BINDING
# Required: yes
#
# This setting sets the binding used to access authentik. Only giving
# a port like ":80" is allowed and will bind port 80 and disable the automatic
# HTTPS deployment. If this value is only set to a port you may need to add a
# override to the "http-entrypoint" service in docker-compose.override.yml to 
# add the port to the port shares
CADDY_AUTHENTIK_BINDING="${CADDY_AUTHENTIK_BINDING}"

# ------------------------------
# AMQP Configuration
# ------------------------------
# Due to RabbitMQ retiring the support for Docker secrets for their docker 
# images the default username and password need to be configured in this file.
# Please make sure the file is protected against unauthorized access. You may 
# also define an external RabbitMQ server here

# AMQP_USER
# Required: no
# Default value: wisdom
#
# The username used for the initial user on the packaged RabbitMQ server. When
# using a external RabbitMQ server you also need to set the username here
AMQP_USER=wisdom

# AMQP_PASSWORD
# Required: yes
#
# The password used for the initial user on the packaged RabbitMQ server. When
# using a external RabbitMQ server you also need to set the password here. 
# Usually when using the internal RabbitMQ server the password will be generated
# for you.
AMQP_PASSWORD=${AMQP_PASS}

# AMQP_HOST
# Required: no
#
# The host which the services connect to when using AMQP as communication method
AMQP_HOST=rabbitmq

# AMQP_PORT
# Required: no
#
# The host which the services connect to when using AMQP as communication 
# method. If the value is not set the default value of 5672 will be used
#AMQP_PORT=

# ------------------------------
# PostgreSQL Configuration
# ------------------------------
# In this section you can configure the packaged PostreSQL server or set up the
# connection to an external PostgreSQL server. When using an external PostgreSQL
# server you need to set the "PG_HOST" setting in this file. Furhtermore, the
# external server needs the PostGIS extension installed.
# IMPORTANT: When changing the user or password here and the local database is
# used, the services will loose access since the postgres container only sets
# these values once at the first start up.

# PG_USER
# Required: no
# Default value: postgres
#
# The default user on the packaged PostgreSQL server which is created at the
# first start. If this value is not set it will default to "postgres" via
# variable replacement.
#PG_USER=

# PG_PASS
# Required: no
#
# The password for the default user on the packaged PostgreSQL server. This is
# usually generated during the creation of this configuration file. Therefore,
# there should be no need to set it here. Furthermore, all shipped containers
# use docker secrets to access this password. If any external containers are not
# compatible with docker secrets, set the password here.
PG_PASS=${PG_PASS}

# PG_HOST
# Required: no
# Default value: postgres
#
# The host on which the PostgreSQL server resides on. If this value is not set 
# it will default to "postgres" via variable replacement, which is the internal
# server
#PG_HOST=

# PG_PORT
# Required: no
# Default value: 5432
#
# The host on which the PostgreSQL server resides on. If this value is not set 
# it will default to "postgres" via variable replacement, which is the internal
# server
#PG_PORT=

# ------------------------------
# General Service Configuration
# ------------------------------

# SERVICE_BRANCH
# Required: yes
# Default value: main
#
# The git branch on which is used for the services
SERVICE_BRANCH=${SERVICE_BRANCH}

# FRONTEND_BRANCH
# Required: yes
# Default value: main
#
# The git branch on which is used for the services
FRONTEND_BRANCH=${FRONTEND_BRANCH}

# COMPOSE_SERVICE_REPLICAS
# Required: no
# Default value: 3
#
# The number of replicas used per service
#COMPOSE_SERVICE_REPLICAS=

# ------------------------------
# Frontend Configuration
# ------------------------------

# FRONTEND_OPEN_ID_CONNECT_AUTHORITY
# Required: yes
# 
# The Authority for the Open ID Connect client used to authenticate users
#FRONTEND_OPEN_ID_CONNECT_AUTHORITY=

# FRONTEND_OPEN_ID_CONNECT_CLIENT_ID
# Required: yes
#
# The Client ID for the Open ID Connect client used in the frontend to 
# authenticate users
#FRONTEND_OPEN_ID_CONNECT_CLIENT_ID=

# ------------------------------
# Water Usage Service Configuration
# ------------------------------

# SERVICE__WATER_USAGE_FORECASTS__AMQP_EXCHANGE
# Required: yes
#
# The AMQP Exchange the RESTful Service and the calculation module use to
# successfully communicate with oneanother
SERVICE__WATER_USAGE_FORECASTS__AMQP_EXCHANGE=water-usage-forecasts

# SERVICE__WATER_USAGE_FORECASTS__AMQP_ROUTING_KEY
# Required: yes
#
# The routing key the RESTful Service uses to route the requests to the
# calculation module. The calculation module gets its value from the same
# setting
SERVICE__WATER_USAGE_FORECASTS__AMQP_ROUTING_KEY=requests
EOF
