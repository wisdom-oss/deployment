# WISdoM OSS Deployment
This article should help you deploying the current live(main) software.

## Currently Active Modules
- Main Routing Proxy (based on [Caddy](https://caddyserver.com/))
- API Gateway (Spring Cloud Gateway)
- Authorization Service (Self-written Python Service)

## Requirements {#requirements}
> **Important Note**  
> This guide may also work with the Windows Subsystem for Linux but this is not
> a supported use case. Even though you may run a fresh install of Ubuntu Server
> on a PC with the Windows Subsystem for Linux enabled.  
> _However_, a completely virtualized Ubuntu Server is supported by the System

OS: Ubuntu Server 20.4 LTS  
Memory: 16GB RAM, _Recommended: 32GB_  
Storage: Minimum: 100GB 
> This data is currently based on the only system available for testing. 
> Therefore these values are not meaningful at the moment. This note
> will be removed once the values are found and tested

The following packages need to be installed on the machine 
- Git
- Docker
- Docker Compose

## 1. Installation of [Docker]() and [Docker Compose]() {#docker-install}

> **ATTENTION**  
> Do not attempt to run the commands written here as the user `root`. Please 
> use `sudo` for running elevated commands.

### Step 1 - Upgrade all system packages to the newest version {#docker-install-step1}

To successfully install docker. Please ensure that all system packages are 
upgraded to their newest version.  
```bash
sudo apt-get update # Get the current package lists
sudo apt-get dist-upgrade # Upgrade all packages to their newest version
# Optional:
sudo apt-get autoremove # Remove all packages currently not needed
```

### Step 2 - Remove old version of the Docker Engine and CLI {#docker-install-step2}

This step is needed to maintain the compatibility with the current releases
for docker. None of the packages may be installed on your system. To make sure
they are not installed you should run the following command. If `apt-get`
reports that none of the packages are found or returns an error for this you
can ignore it.
```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```
### Step 3 - Installing the Docker Engine and Docker Compose {#docker-install-step3}
You now have the choice between using the convenience script supplied by
Docker Inc or doing some of the steps manually.

#### Step 3.1 - Using the convenience script {#docker-install-step3.1}

> * This script needs to be executed by `root` or with `sudo` privileges
> * The script is only designed for making a very first installation of
>   Docker on the machine

```bash
curl -fsSL https://get.docker.com -o get-docker.sh # Download the convenience script
sudo sh get-docker.sh # Run the convenience script
```

#### Step 3.2 - Manually installing docker {#docker-install-step3.2}

1. Update the package index
    ```bash
    sudo apt-get update
    ```
2. Install HTTPS support for apt
   > Depending on your base installation some or all packages may be installed
   > already. The command will skip already installed packages.
   ```bash
   sudo apt-get install \
   ca-certificates \
   curl \
   gnupg \
   lsb-release
   ```
3. Add Docker's GPG key
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
   sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   ```
4. Add the docker repository to the apt sources
   ```bash
   echo \
   "deb [arch=$(dpkg --print-architecture) \
   signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
   https://download.docker.com/linux/ubuntu \
   $(lsb-release -cs) stable" | \
   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```
5. Install the Docker Engine
   ```bash
   sudo apt-get update # Update the package sources
   sudo apt-get install docker-ce docker-ce-cli containerd.io # Install the packages needed for Docker
   ```

## 2. Get the files for the deployment {#get-files}

### 2.1 - Download the files to your computer and upload them to the server {#get-files-option1}

> **Note**  
> When using this method you will need to update your installation manually 
> every time a new version of the deployment files is released. To enable a
> more automatized update process and enable revert features use the [second
> method](#get-files-option2)


After successfully installing the Docker Engine and Docker Compose you now need
to download this repository to your server. Use one of the following links to 
download the repository and its contents as:  
- [IP archive](https://gitlab.uni-oldenburg.de/wisdom-oss/deployment/-/archive/main/deployment-main.zip) 
- [Tarball with gzip](https://gitlab.uni-oldenburg.de/wisdom-oss/deployment/-/archive/main/deployment-main.tar.gz)
- [Tarball with bzip2](https://gitlab.uni-oldenburg.de/wisdom-oss/deployment/-/archive/main/deployment-main.tar.bz2)
- [Tarball](https://gitlab.uni-oldenburg.de/wisdom-oss/deployment/-/archive/main/deployment-main.tar)

After downloading the archive please decompress it and upload it to your server
in a location you have read/write permission.

### 2.2 - Download the files directly onto the server _(Recommended)_ {#get-files-option2}

1. Login onto your server via `ssh` or by other means.
2. Create a new directory for the files
   ```bash
   sudo mkdir -p /opt/wisdom-oss
   ```
3. Download the repository contents to the server
   ```bash
   cd /opt/wisdom-oss # Change into the directory for the files
   sudo git clone https://gitlab.uni-oldenburg.de/wisdom-oss/deployment.git . # Clone this repository
   ```
   > During the cloning of the repository you may be asked to enter your 
   > credentials. If this is the case please contact us [via mail](mailto:wisdom@uol.de)