<p align="center">
<img src="https://raw.githubusercontent.com/wisdom-oss/brand/main/silhoutte.svg" height=100px>
</p>

# WISdoM OSS Deployment
> :warning: The instructions used in this repository aim at the current LTS
> of Ubuntu Server. Other operating systems including the WSL may use other 
> commands or are not compatible.

This repository contains all needed files for deploying the standard 
installation of the WISdoM platform. Since the project utilizes a microservice 
architecture the project uses [Docker](https://docs.docker.com) as container 
orchestration tool.

It deploys the following standard services:
  - HTTP Entrypoint [a [Caddy](https://caddyserver.com/) webserver]
  - API Gateway (a [Kong Gateway](https://docs.konghq.com/gateway/latest/))
  - [Authentik](https://goauthentik.io/) as authorization server
  - PostgreSQL as main database with the [PostGIS](https://postgis.net/) extension
  - A basic water usage forecasting tool
  - A water usage forecasting tool based on [Prophet](https://facebook.github.io/prophet/)
  - A basic geospatial data service
  - A service for storing files (e.g. PDFs, Excel sheets)

## Installation
### Prerequisites

| Hardware                                                       | Software                             |
|----------------------------------------------------------------|--------------------------------------|
|Memory: min. 16 GB, _recommended: 32GB_<br>Storage: min. 100 GB | Git, Docker, Docker Compose, OpenSSL |


### Installing the platform
To install the software you need to clone the repository on the machine that is
supposed to host the platform. You may either connect via SSH or use the 
Terminal of your choice directly on the machine. However you need to have root
privileges on the machine!

1. Clone the repository onto your machine
    ```sh
    git clone https://github.com/wisdom-oss/deployment.git /opt/wisdom
    ```
2. Go into the just cloned repository
    ```sh
    cd /opt/wisdom
    ```
3. Execute the `generate_config.sh` file
    ```bash
    ./generate_config.sh
    ```
    Remember the passwords printed out to the console
4. If needed update the configuration file
    ```bash
    nano wisdom.conf
    ```
5. Build all needed docker images
    ```bash
    docker compose build
    ```
6. Prepare API Gateway Database
    ```bash
    docker compose run api-gateway kong migrations bootstrap
    ```

6. Start up the containers
    ```bash
    docker compose up -d
    ```

Now the platform ist deployed on your machine and ready to be configured.

### Configure the platform
#### Authentik


## FAQ
### Why authentik as authorization server
Choosing a authorization service was kind of a struggle in the beginning since 
writing a microservice containing some basic OAuth2.0 implementation sounds nice,
but it wouldn't support importing users from other sources like LDAP, SAML, 
AzureAD or another OpenID Connect provider. But this kind of functionality is
supported by authentik out of the box with a simple UI for configuration.

Therefore the choice fell on authentik for a authorization server. You may
replace it with another service of your choice, as long as it supports the
OpenID Connect protocol.