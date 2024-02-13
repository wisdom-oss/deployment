#!/usr/bin/env bash
set -e
# WISdom Platform initialization script
#
# This script is intended as a initialization script after the WISdoM platform
# repository has been cloned. This script should be used to allow a initial
# configuration of the WISdoM platform.
#
# The script:
#
#   - Requires `root` or `sudo` privileges to be executed
#   - Attempts to detect your container runtime and configures the stack of
#     containers running in the platform
#   - Configures passwords for containers that require them
#   - Starts the configuration processes for the authentication platform, if
#     needed
#
# ==============================================================================

if [ -f wisdom.conf ]; then
    echo -e "\e[1;33m[WARNING]\e[0m Preexisting configuration file found!"
    echo -e "Rerunning the initialization process will break the database connections and"
    echo -e "will possibly break other containers."
    read -r -p "Do you want to continue? [y/N]: " response
    case $response in
        [yY][eE][sS]|[yY])
            mv wisdom.conf .wisdom.conf
            chmod 600 .wisdom.conf
            ;;
        *)
            echo -e "exiting initialization process"
            exit 1
        ;;
    esac
fi

echo "Which container engine is installed on your host?"
echo ""
echo "Available engines:"
echo "- Docker [1] (default)"
echo "- Podman [2]"

while [ -z "${CONTAINER_ENGINE}" ]; do
  read -r -p  "Choose the Branch with it´s number [1/2] " response
  case $response in
    [2])
      CONTAINER_ENGINE="podman"
      COMPOSE_TOOL="podman-compose"
      ;;
    [1])
      CONTAINER_ENGINE="docker"
      COMPOSE_TOOL="docker compose"
      ;;
    *)
      CONTAINER_ENGINE="docker"
      COMPOSE_TOOL="docker compose"
    ;;
  esac
done

HOSTNAME=$(hostname -f)
if [ -a /etc/timezone ]; then
  TIMEZONE=$(cat /etc/timezone)
elif [ -a /etc/localtime ]; then
  TIMEZONE=$(readlink /etc/localtime|sed -n 's|^.*zoneinfo/||p')
fi

echo "The WISdoM platform utilizes the OpenID Connect standard for authenticating,"
echo "authorizing and validating access to the platform. The platform can use an"
echo "already existing OpenID connect server and skip the deployment of a new"
echo -e "OpenID connect compatible server.\n"
read -r -p "Do you want to use a existing OpenID Connect Server? [y/N]: " response

case $response in
        [yY][eE][sS]|[yY])
            USE_EXTERNAL_OIDC="true"
            read -r -p "OpenID Connect Discovery Endpoint URI: " OIDC_DISCOVERY_ENDPOINT
            read -r -p "OpenID Connect Client ID: " OIDC_CLIENT_ID
            ;;
        *)
            OIDC_DISCOVERY_ENDPOINT=""
            OIDC_CLIENT_ID=""
        ;;
    esac

cat << EOF > wisdom.conf
# ===================== WISdoM Platform Configuration File =====================
# This file contains all configuration options that may be modified and control
# the WISdoM platform. All options are configured with sensible defaults or
# automatically generated values.
#
# ----------------
# HTTP Entrypoint
# ----------------
# The HTTP entrypoint manages the initial routing between the API gateway and
# the frontend which runs in a different container. The entrypoint utilizes the
# Caddy webserver. The caddy server will host the frontend on port 80 by default
# and hosts the authentik Server on port 81 by default.
# For formatting information of the following strings, please read the 
# documentation of the Caddy webserver
ENTRYPOINT_FRONTEND_ADDRESS="${HOSTNAME}:80"
EOF

if [[ "$USE_EXTERNAL_OIDC" == "true" ]]; then
    cat << EOF >> wisdom.conf
# ENTRYPOINT_OIDC_SERVER_ADDRESS="${HOSTNAME}:81"
EOF
else
    cat << EOF >> wisdom.conf
ENTRYPOINT_OIDC_SERVER_ADDRESS="${HOSTNAME}:81"
EOF
fi

cat << EOF >> wisdom.conf
# -------------------------
# PostgreSQL Configuration
# -------------------------
# The PostgreSQL server acts as central data storage for the platform and it's
# data. It is configured with the timescaleDB and PostGIS as extensions to 
# support storing timeseries and geospatial data
PG_USER=postgres
PG_PASS=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)
PG_HOST=postgres
PG_PORT=5432

# -----------------------
# Platform Configuration
# -----------------------
# Since the frontend is built locally to allow changing the OpenID Connect
# provider it is possible to change the branches used to build the frontend
# container. Furthermore, it is possible to select the branch that shall be
# used for the backend services.
# When chaning the branch for the backend services. It is automatically applied
# to all backend services running in the WISdoM platform. Services that are
# shipped as prebuilt container use the BACKEND_IMAGE_VERSION option to control
# the image version pulled.
FRONTEND_BRANCH=main
BACKEND_BRANCH=main
BACKEND_IMAGE_VERSION=latest
EOF