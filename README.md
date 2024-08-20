> [!CAUTION]
> This rework is under constant change. The instructions as well as the source
> code may change at any given moment. **Do not use this guide to setup a new
> installation of the WISdoM platform** 

<div align="center">
<img height="150px" src="https://raw.githubusercontent.com/wisdom-oss/brand/main/svg/standalone_color.svg">
<h1>Deployment</h1>
<p>🚀 files and documentation for deploying the platform</p>
<img alt="Static Badge" src="https://img.shields.io/badge/podman-experimental-grey?style=for-the-badge&logo=podman&labelColor=892CA0">
<img alt="Static Badge" src="https://img.shields.io/badge/docker-compatible-grey?style=for-the-badge&logo=docker&logoColor=white&labelColor=2496ED">
</div>

> [!NOTE]
> This guide does not explain how to install `docker` or `podman` on your host.
> Please refer to the installation manuals for the respective container
> orchestrator for instructions:
>   - https://docs.docker.com/engine/install/
>   - https://podman.io/docs/installation

### System Requirements
* 100 GB Storage Space
* Debian-based x64 operating system
* Internet Access

> [!IMPORTANT]
> The WISdoM Platform is shipped **without** an OpenID Connect provider.
> You either need to self-host a OpenID Connect provider (e.g, [authentik], 
> [Authelia]) or use a SaaS solution like [auth0] or [Okta]

[authentik]: https://goauthentik.io/
[Authelia]: https://www.authelia.com/
[auth0]: https://auth0.com
[Okta]: https://www.okta.com

### Setup
To deploy the WISdoM Platform you'll only need to pull this repository using
the following command:
```shell
git clone https://github.com/wisdom-oss/deployment.git wisdom
```

