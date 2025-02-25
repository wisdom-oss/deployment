<div align="center">
<h1>Installation Guide</h1>
</div>

> [!WARNING] 
> This document will guide you through the installation and 
> configuration of the WISdoM platform. The instructions shown here only apply
> to a clean and freshly installed operating system supported by the platform.

> [!NOTE]
> All commands in this guide require root permissions


## System Requirements
The WISdoM platform currently supports the following operating systems in 
their AMD64 and ARM64 versions:
  - Debian 11, 12
  - Fedora 41
  - RedHat Enterprise Linux 8, 9
  - Ubuntu 22.04 LTS (Jammy Jellyfish), 24.04 LTS (Noble Numbat)

The platform has not been tested on other operating systems.
The platform will not support other processor architectures.

Furhtermore, you need to have `git`, `openssl` and a text editor of your choice
installed.

## Install Docker
> [!NOTE]
> Using Podman or another OCI-compliant software as container orchestrator is
> not supported by the platform nor their maintainers.

> [!NOTE]
> For Post-Install tasks and recommendations please visit:
> https://docs.docker.com/engine/install/linux-postinstall/


### Debian
> [!CAUTION]
> If you use `ufw` or `firewalld` to manage your firewall, exposed container
> ports will bypass the iptable rules set by either of the frontends as Docker
> routes the traffic before the traffic reaches the chains setup by `ufw` or
> `firewalld`

```shell
# Remove old and unofficial docker packages
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

# add docker's GPG key
apt-get update
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# add docker's APT repository to the sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# update the APT repositories
apt-get update

# install the latest version of docker and docker compose
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Fedora
```shell
# remove old and unofficial docker packages
dnf remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc

# setup the repository
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# install the latest version of docker and docker compose
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# start docker and enable autostart on boot
systemctl enable --now docker
```

### Ubuntu
> [!CAUTION]
> If you use `ufw` or `firewalld` to manage your firewall, exposed container
> ports will bypass the iptable rules set by either of the frontends as Docker
> routes the traffic before the traffic reaches the chains setup by `ufw` or
> `firewalld`

```shell
# Remove old and unofficial docker packages
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

# add docker's GPG key
apt-get update
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# add docker's APT repository to the sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# update the APT repositories
apt-get update

# install the latest version of docker and docker compose
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### RedHat Enterprise Linux (RHEL)
```shell
# remove old and unofficial docker packages
dnf remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc

# setup the repository
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# install the latest version of docker and docker compose
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# start docker and enable autostart on boot
systemctl enable --now docker
```

## Prepare the platform files

Start by cloning the `wisdom-oss/deployment` repository onto your server and
inizialize the configuration file
```
# clone repository over http
git clone https://github.com/wisdom-oss/deployment.git /opt/wisdom

# open the repository
cd /opt/wisdom

# copy the sample configuration file
cp wisdom.sample.conf wisdom.conf
```

### Configuring a database password
> [!CAUTION]
> If the database password in the configuraiton file is changed after the 
> platform has been started for the first time, all services will loose access
> to the database as the change is not picked up by the database container

> [!NOTE]
> If you want to use a already existsing database server, please check the
> following document: [Using an existing database]

[Using an existing database]: ./external-db.md

```shell
sed -i "s/^#DATABASE_PASSWORD=.*/DATABASE_PASSWORD=$(openssl rand -hex 16)/g" wisdom.conf
```

### Configuring OpenID Connect
> [!IMPORTANT]
> The OpenID Connect Provider supplied needs to support the OpenID Connect
> Discovery Specification and is required to have a vaild, not self-signed
> HTTPS certificate.

Now open the configuration file with a text editor and set the values for the
following environment variables
  - `OIDC_ISSUER`
  - `OIDC_CLIENT_ID` 
  - `OIDC_CLIENT_SECRET`


## Starting the platform
To start the plaform after the initial configuration you'll need to pull the
images for the different services.
Depending on your internet speeds this might take a while.
```shell
docker compose pull
```

After all images have been pulled you only need to execute the following command
to start up all containers and put them into the background.
This will also create the required networks and volumes to store the data on 
your instance.
```shell
docker compose up -d
```

After the command returned without any error your platform will be available at
http://localhost:8000

## Post Installation
As the platform is only available on `localhost` it's recommended to create or
run a reverse proxy which will also hande TLS-/HTTPS-Termination to protect the
data during it's transmission to your server.
There is plenty of software for this usecase. Due to the easy setup this project
recommends [Caddy] as it allows the automatic handling of retrieving and
renewing certificates and has a simple configuration syntax.

[Caddy]: https://caddyserver.com/