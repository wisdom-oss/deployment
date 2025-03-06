# Contributing to WISdoM Deployment
Thank you for contributing to the deployment of the _WISdoM platform_.
This document outlines everything you need to know to get started and to
contribute effectively.

## About the project
This repository contains all files required to spin up an instance of the
platform.
We use [Docker Compose] as the deployment method as it allows prebuilding the
[frontend] and [backend services] on a centralized platform.

[frontend]: https://github.com/wisdom-oss/frontend/
[Docker Compose]: https://docs.docker.com/compose/
[backend services]: https://github.com/orgs/wisdom-oss/repositories?q=topic%3Abackend

## Development Tools
### Docker and Docker Compose
[Install Docker] and [Docker Compose] on your host as pointed out in the 
documentation.

## Code Organization
**Important Files**
  - `compose.yml`: Base Containers always needed in a deployment
  - `services.compose.yml`: Definition of backend services

## Adding a new service

### 0. Familiarize
  - Read the Compose [Quickstart](https://docs.docker.com/compose/gettingstarted/)
  - Read about [Including Compose Files](https://docs.docker.com/compose/how-tos/multiple-compose-files/include/)
  - Read about [Fragments](https://docs.docker.com/reference/compose-file/fragments/)
  - Read about [Trafik and Docker](https://doc.traefik.io/traefik/providers/docker/)

### 1. Add the service to the deployment
> [!NOTE]
> Ensure the service contains a `Dockerfile` or has an image available

Add an entry to the `services.compose.yml` file using one of the following 
templates.
Please replace all instances of `<your-service-name>` with the desired service
name.
Also replace all `<your-api-path>` instances with the path under which the
API of the service will be available.
If the service contians an api documentation please match the API path set in
the compose file with the documented base path.
If the documented base path is just `/` then you may choose one of your liking.

**Ensure that your new service definition is above the three dots at the end
of the YAML file**

<details>
<summary>Case 1: Service has an image available</summary>

```yaml
services:
    # … all already deployed services

    <your-service-name>:
        image: <image-name>:${BACKEND_VERSION:-latest} # todo: set image name
        restart: unless-stopped
        scale: ${SERVICE_REPLICAS:-1}
        depends_on: *dbDependency
        environment: *dbEnvironment
        <<: *extraHosts
        labels:
            - "traefik.enable=true"
            - "traefik.http.routers.<your-service-name>.middlewares=<your-service-name>PrefixStrip"
            - "traefik.http.routers.<your-service-name>.rule=PathPrefix(`/<your-api-path>`)"
            - "traefik.http.middlewares.<your-service-name>PrefixStrip.stripprefix.prefixes=/<your-api-path>"

```

</details>
<details>
<summary>Case 2: Service has <b>no</b> image available</summary>

```yaml
services:
    # … all already deployed services

    <your-service-name>:
        build:
            context: <the-public-http-repo-url>
            # if the Dockerfile is not in the top-level directory please specify
            # the relative path to the Dockerfile here
            # dockerfile: <relative-path-to-dockerfile>
        restart: unless-stopped
        scale: ${SERVICE_REPLICAS:-1}
        depends_on: *dbDependency
        environment: *dbEnvironment
        <<: *extraHosts
        labels:
            - "traefik.enable=true"
            - "traefik.http.routers.<your-service-name>.middlewares=<your-service-name>PrefixStrip"
            - "traefik.http.routers.<your-service-name>.rule=PathPrefix(`/<your-api-path>`)"
            - "traefik.http.middlewares.<your-service-name>PrefixStrip.stripprefix.prefixes=/<your-api-path>"

```

</details>

### 2. Validate your compose files
> [!TIP]
> Create a configuration file as lined out in the [installation guide] to allow
> a smoother terminal experience
>
> [installation guide]: docs/install.md

Now validate your compose files, to check for syntax errors and indent issues
```bash
docker compose convert
```