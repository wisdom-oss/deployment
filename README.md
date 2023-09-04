<div align="center">
<img height="150px" src="https://raw.githubusercontent.com/wisdom-oss/brand/main/svg/standalone_color.svg">
<h1>Deployment</h1>
<p>
<span>🔐</span>
All steps require administrative priviliges on the host machine to work
</p>
<p>
<span>🦺</span>
In its default configuration, Docker modifies the iptables to allow port 
publishing. The modifications bypass the iptables set by firewall applications.
Take care when opening up ports!
</p>
</div>

To allow a unified deployment of the project it utilizes
[Docker](https://www.docker.com) together with 
[Docker Compose](https://docs.docker.com/compose/) as deployment mechanism.

> The following instructions and commands aim to support the
> current LTS Version of Ubuntu (22.04). Both the desktop and server variants
> are supported.
>
> _Using a different operating system or using the Windows Subsystem for Linux
> (WSL) is not supported by these instructions as they may need anther syntax
> or may not even support Docker out-of-the-box_

## Prerequesites
This section will be used to install the following prerequesites:
* Docker
* Docker Compose
* Git

### Docker and Docker Compose
There are two ways to install docker on your machine:
1. Using the convenience script
2. ✨ Manually adding the package repository and installing the packages

#### Using the convenience script

> 🛑🦺 Executing scripts from an untrusted source may result in a
> broken system configuration as well as secutiry vulnerabilities by installed
> packages or the contained commands.
>
> _Always verify the contents of a script by reading through it. If you don't
> understand every command **do not execute it!**_

The first is the 
[convenience script](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script) 
created by docker to allow a realatively easy installation that may be used for
development environments or newcomers that do not feel secure enough around the
terminal.

Please go to the documentation about the convenience script for further
information on the usage and prerequesites

[_External Documentation_](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script)

#### ✨ Manual install using the package repository

##### Removing old versions of Docker
> 🛑 Software depending on the old packages will stop functioning and may not
> be compatible with the packages published by Docker Inc.

Since this guide will use the most up to date version of Docker, released 
directly by Docker Inc., the versions deployed over the default repositories
need to be removed beforehand. To remove them you will need to uninstall the
following packages:
* `docker.io`
* `docker-compose`
* `docker-doc`
* `podman.docker`
* `containerd`
* `runc`

To uninstall these packages use the following command which tries to remove
the packages:
```sh
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do apt-get remove $pkg; done
```

##### Adding the new repository

Since now all possibly conflicting packages have been removed, update your
package index once using the following command:
```sh
apt-get update
```

Now install the following packages, that allow the usage of the signingkey used
to digitally sign the packages in the repository, to make sure that the
packages downloaded from the repository are in fact from Docker Inc.:
* `ca-certificates`
* `gnupg`
```sh
apt-get install ca-certificates gnupg
```

Now add the GPG signing key issued by Docker Inc. to the list of known
keys:
```sh
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
```

Now add the repositroy to the known repositories of APT
```sh
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
```

To activate the repository for installing Docker update the package repository
one again using:
```sh
apt-get update
```

##### Install the packages
Now install the Docker Engine and the Compose Plugin
```sh
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

🎉 And thats it. Now your server has Docker and Docker Compose installed and
is ready to run the WISdoM project

> Currently the only user allowed to issue `docker` commands is `root`.
> To allow other users to run `docker` commands without having `sudo`
> privileges, read the information on the following website:<br/>
> https://docs.docker.com/engine/install/linux-postinstall

### Git
Usually `git` is already included in a standard Ubuntu Server installation.
However, if you are using the desktop variant or used a customized server image 
for the initial installation of the operating system, you might need to install
`git`.

#### ✨ Installing stable from the official package repositories
To install `git` from the standard package repositories just run the following
commands:
```sh
sudo apt-get update
sudo apt-get install git
```

#### Installing upstream stable from PPA[^1]
> 🦺 Packages from PPAs may contain unwanted code and could introduce 
> vulnerabilities to your system, since the code is not checked by a 3rd-party!
> 
> Proceed with care and at your own risk!

To allow the usage of the very latest stable version of `git` directly built
from source, you may use the PPA. This is not recommended since using a PPA
may impact the systems stability.

If you still want to use the latest upstream version, you need to execute the
following command to add the PPA to the sources that APT uses
```sh
apt-add-repository ppa:git-core/ppa
```

Now update your package index and install `git`
```sh
apt-get update
apt-get install git
```


## Installing WISdoM
Since now all prerequisites are installed the process of getting the latest
version of WISdoM may start.

### Clone the `deployment` repository
To clone the repository use the following command. This clones the repository
using HTTPS.

```sh
git clone https://github.com/wisdom-oss/deployment.git
```

### Generate a configuration file

> 🛑🦺 Executing scripts from an untrusted source may result in a
> broken system configuration as well as secutiry vulnerabilities by installed
> packages or the contained commands.
>
> _Always verify the contents of a script by reading through it. If you don't
> understand every command **do not execute it!**_

To generate the required configuration file execute the `generate_config.sh`
script contained in the repository

```sh
bash ./generate_config.sh
```

If needed you may edit the generated `wisdom.conf` file using your favourite
console text editor (e.g `nano`, `vim`)

### Configure the Authentification Platform
> 🛑 If the authentification platform is not configured the WISdoM platform 
> will not work correctly!

Since the authentification platform requires some configuration before it works
correctly, start up just the authentification platform for configuration.

```sh
docker compose --profile authentik-config up -d
```

#### Creating the administrative user
> 🦺 Please use a strong and secure password for the `akadmin` user since this
> account will be the initial super user on the platform. Should the password
> be leaked or cracked, an attacker could steal other users credentials or
> access external user sources

Since the authentification platform does not deploy with a default password you
need to set the initial password for the `akadmin` user.

1. Navigate to the following address: `http://<machine-ip-or-hostame>:9000/if/flow/initial-setup/`

2. Set a _secure_ password for the `akadmin` user and set an administrators
   email.

#### Updating the OpenID `profile` scope

Due to the default configuration of the authentification platform, users will
not be assigned to the parent groups they are members of when requesting the
`profile` scope.
Since the parent groups may be important for the API requests,
the definition of the profile scope needs to be updated in the authentification
platform.


> 🛑 Pay attention when copying the configuration. A typo could result in an
> inaccessible platform!

1. Navigate to the Administrative UI `http://<machine-ip-or-hostame>:9000/if/admin`
2. Open the `Cusomization` menu and select the `Property Mappings`
3. Show the managed mappings by disabling the switch labled `Hide managed mappings`
4. Edit the `authentik default OAuth Mapping: OpenID 'profile` mapping
5. Replace the current contens of the mapping with the following code and save
   the changes.
    ```py
    def resolve_parents(group, parentList):
        parentList.append(group)
        if group.parent is not None:
            parentList.append(group.parent)
            resolve_parents(group.parent, parentList)

    userGroups = [g.name for g in user.ak_groups.all()]
    for group in user.ak_groups.all():
        if group.parent is not None:
            parents = []
            resolve_parents(group, parents)
            for parent in parents:
                userGroups.append(parent.name)

    return {
        "name": request.user.name,
        "given_name": request.user.name,
        "preferred_username": request.user.username,
        "nickname": request.user.username,
        "groups": list(set(userGroups)),
        "picture": request.user.avatar,
        "isAdmin": request.user.is_staff
    }
    ```

#### Create a OAuth 2.0/OpenID Connect provider and application for the frontend
To allow the frontend to use the authentification platform for logging in,
a OAuth 2.0/OpenID Connect provider is required.
Furhtermore, an application entry is required to activate the provider and let
the authentification platform manage access the the application.

##### Creating a OAuth 2.0/OpenID Connect provider
> 🦺 Since the frontend runs in a browser and therefore is considered a public
> client, make sure to set the client type to `public`.

1. Navigate to the Administrative UI `http://<machine-ip-or-hostame>:9000/if/admin`
2. Open the `Applications` menu and select `Providers`
3. Select the `OAuth2/Open ID Provider`
4. Now set the client type as `public` and set the redirect URIs/Origin regex to
   `.*`
5. Save the new provider

##### Creating a new appliction entry
> 🛑 Make sure to select the correct provider, if there are multiple providers
> available. If the wrong provider is selected, the platform will generate
> authentification errors

1. Navigate to the Administrative UI `http://<machine-ip-or-hostame>:9000/if/admin`
2. Open the `Applications` menu and select `Applications`
3. Create a new application
4. Set the fields to your own liking
5. Under the `provider` field, select the just created OAuth 2.0/OpenID Connect 
   provider

##### Updating the platform configuration
Now the generated client id and open id connect issuer need to be set in the
platform configuration to allow the frontend to pick up those values during
the build proccess.

1. Navigate to the Administrative UI `http://<machine-ip-or-hostame>:9000/if/admin`
2. Open the `Applications` menu and select `Providers`
3. Select the `OAuth2/Open ID Provider`
4. Open the provider you created in the previous step.
5. Open the `wisdom.conf` file on the server
6. Assign the OpenID configuration url displayed in the authentification 
   platform to the `FRONTEND_OPEN_ID_CONNECT_AUTHORITY` variable
7. Assign the client id displayed in the authentification platform to the
   `FRONTEND_OPEN_ID_CONNECT_CLIENT_ID` variable

#### Clean up
Since now all required configuration steps have been completed the platform
is ready to be built and hosted on the server. However, some cleanup steps are
required to stop zombie containers from existing. Since only the 
authentification platform is currently running, stop it

```sh
docker compose --profile authentik-config down
```

### Building the microservices and the frontend
Since all configuration and cleanup measures have been taken, start to build
the containers for the WISdoM platform.

> ⌛ Depending on the hardware configuration, the build process may take a
> long time. Durations of up to 45 minutes have been reported...
> 
> _Time to get a coffee and a snack_ ☕🍩

```sh
docker compose build
```

### Preparing the API gateway
Since the API gateway used for the WISdoM platform needs to initialize the
database before starting it for the first time, run some needed migrations
and the database bootstrap
```sh
docker compose run api-gateway kong migrations bootstrap
```

### Start up all containers
After the API gateway has been configured, no further steps are required,
except of starting up the compose file
```sh
docker compose up -d
```
After about 2-3 minutes the frontend will be accessible under the bindings
set up while generating the configuration file.

<!-- Footnotes below this point -->
[^1]: PPA is an acroynm for a Personal Package Archive. These type of archives
      are directly maintained by the developers publishing the packages 
      available in them. _However, packages installed from them are not from
      official sources any may impact the stablility of your system. Use with
      care!_
    