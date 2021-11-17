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
