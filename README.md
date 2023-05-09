<p align="center">
<img src="https://raw.githubusercontent.com/wisdom-oss/brand/main/silhoutte.svg" height="100px"/>
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
4. If needed update the configuration file
    ```bash
    nano wisdom.conf
    ```
5. Startup Authentik for configuration
    > :warning: Only run the specified command to stop all services from 
        starting up while trying to start up the configuration for authentik.
    > :information_source: This step will also initialize the database, if the
        database is started for the first time
    ```bash
    docker compose --profile authentik-config up -d
    ```

    Now follow the steps described further down under `Configure the platform > Authentik`
    after accessing the authentik UI on port `9000`

    After finishing the needed setup steps shut down the containers with the 
    following command:
    ```bash
    docker compose --profile authentik-config down
    ```

6. Build all needed docker images
    > :warning: The build process for the frontend will fail is no OpenID
        configuration was set.
    > :information_source: The build process may take up to 30 minutes!
    ```bash
    docker compose build
    ```
7. Prepare API Gateway Database
    ```bash
    docker compose run api-gateway kong migrations bootstrap
    ```
8. Start up the containers
    ```bash
    docker compose up -d
    ```

Now the platform ist deployed on your machine and ready to be used.

### Configure the platform
#### Authentik
##### Administrative User
Since authentik will not be preconfigured with a password and user you need
to create the password for the initial user `akadmin`. To achive this, you need
to open the authentik UI via the binding you entered during the configuration
generation on the following path: `/if/flow/initial-setup/`. You may now set
the administrators E-Mail Address and password. Make sure that the password is
secure!

##### Change the OpenID `profile` scope
Due to the authentication measures taken by the platform you need to change
authentik's implementation of the `profile` OpenID Connect scope.

1. Open the Authentik Admin UI (`/if/admin/`)
2. Navigate to the _Property Mappings_ which are located under the _Customization_
    entry in the sidebar
3. Enable the display of the managed mappings by flipping the switch labeled
    _Hide managed mappings_
4. Edit the mapping named `authentik default OAuth Mapping: OpenID 'profile'`
5. Replace the contents of the mapping with the following code:
    ```python
    # This function will help resolving the parents of a group
    def resolve_parents(group, parentList):
        parentList.append(group)
        if group.parent is not None:
            parentList.append(group.parent)
            resolve_parents(group.parent, parentList)
    
    # Now get all groups the user is directly assigned to
    userGroups = [g.name for g in user.ak_groups.all()]

    # Now resolve all parents of a group if the group has a parent
    for group in user.ak_groups.all():
        if group.parent is not None:
            parents = []
            resolve_parents(group, parents)
            for parent in parents:
                userGroups.append(parent.name)

    return {
        # Because authentik only saves the user's full name, and has no concept of first and last names,
        # the full name is used as given name.
        # You can override this behaviour in custom mappings, i.e. `request.user.name.split(" ")`
        "name": request.user.name,
        "given_name": request.user.name,
        "preferred_username": request.user.username,
        "nickname": request.user.username,
        # groups is not part of the official userinfo schema, but is a quasi-standard
        "groups": list(set(userGroups)),
    }
    ```
6. Save the edited mapping

##### Creating a OpenID Connect Provider for the frontend
1. Open the administrative UI of your authentik installation
    `/if/admin/`

2. Now navigate to the Providers using the left sidebar `Applications/Providers`

3. Now Create a new `OAuth2/OpenID` provider with the client type set to 
    `public`.

4. Now set the `Client ID` in the `wisdom.conf` file together with the 
    OpenID Configuration URL displayed in the Provider Details. When using
    `localhost` in the OpenID Configuration ID the client accessing the 
    frontend expects authentik to be running on the client!


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