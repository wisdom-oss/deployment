<div align="center">
<img height="192px" src="https://raw.githubusercontent.com/wisdom-oss/brand/main/svg/standalone_color.svg">
<h1>Deployment Guide</h1>
<h3>deployment</h3>
<p>🚀 files and documentation for deploying the platform</p>
<img alt="Static Badge" src="https://img.shields.io/badge/podman-compatible-brightgreen?style=for-the-badge&logo=podman">
<img alt="Static Badge" src="https://img.shields.io/badge/docker-compatible-brightgreen?style=for-the-badge&logo=docker&logoColor=white">
</div>

> [!TIP]
> To lower the possibilities of confusion the following words are defined as
> listed below:
>   - Host: The machine the wisdom platform will be installed to

> [!TIP]
> The commands in this guide require `root` permissions on the host. Please check
> if you have the needed permissions before continuing. 

> [!NOTE]
> The WISdoM platform supports all x86_64 platforms supported by Docker/Podman.
> Please check the [Docker]/[Podman] documentation for further information on
> compatibility.

[Docker]: https://docs.docker.com/engine/install/
[Podman]: https://podman.io/docs/installation


This repository contains all files needed to deploy the WISdoM platform onto a
new host.
To allow an easier management of the containers created and needed for the
WISdoM platform the Containers are deployed in a stack which is managed by the
selected container management (e.g. Docker).

## Deploying the platform
### 0. Prerequisites
To be able to use the WISdoM platform on your host, the following prerequisites
are required for a successfully deployment:

**A selection of either**
  - Docker ([Instructions](https://docs.docker.com/engine/install/))
  - Docker Compose ([Instructions](https://docs.docker.com/compose/install/))

**or**
  - Podman ([Instructions](https://podman.io/docs/installation))
  - Podman Compose ([Instructions](https://podman.io/docs/installation))

accompanied by the following executables:
  - `git`

### 1. Clone this repository
Since all configuration updates are delivered by this repository, you need to
clone this repository to allow updating via `git`.
You may pull this repository via HTTPS or SSH using the following commands:

```sh
git clone https://github.com/wisdom-oss/deployment.git wisdom # for cloning via HTTPS
git clone git@github.com:wisdom-oss/deployment.git wisdom # cloning via SSH
```

### 2. Generate your configuration file
> [!NOTE]
> If you already use an OpenID Connect compatible server you may specify it
> during the initialization.
> If not, [Authentik] will be deployed alongside with the WISdoM platform to
> enable authentication and identity management.

[Authentik]: https://goauthentik.io/docs/

Now execute the `init.sh` file to generate your configuration file which is used
to store and handle all configurable options.

```sh
cd wisdom
chmod +x init.sh
./init.sh
```

### 3. Prepare Database
> [!IMPORTANT]
> Please replace the `docker compose` command with `podman-compose` if you
> installed Podman as your container engine

Now you need to prepare the PostgreSQL database to allow the API Gateway and
depending on your configuration the authentik containers to store data in the
database.

```sh
docker compose up -d postgres
# create the required database for the API Gateway
docker compose exec -u postgres postgres psql -c "CREATE DATABASE kong"; 
# (optional) create the database for Authentik
docker compose exec -u postgres postgres psql -c "CREATE DATABASE authentik";
```
