<h1 align="center">Connecting to an external Minio Storage</h1>

## Disable the minio container

To decrease the memory and processor consumption by the platform you can disable
the minio container on your host while using an external platform.
The container will still be created but is changed to exit directly after
starting.

To apply this configuration, open or create a file called `compose.override.yml`
and insert the following content

```yml
services:
  object-storage:
    command: ["/bin/true"]
    restart: no
```

## Change database dependency condition

Since Docker Compose now still expects the database container to run before the
other services can start, you now need to edit your configuration file to change
that behaviour.

Open the `wisdom.conf` file you created during the setup of the platform.
Uncomment the line containing the key `MINIO_REQUIRED_STATE`.
This lets the services start after the minio container exited successfully
(which has been configured in the previous step).

## Set and apply connection details

Afterwards, open your configuration file and configure the `MINIO_*` to the
values the external object storage requires.

To apply the configuration to the running services and to disable the database
container run the following command which recreates all containers to allow them
to connect using the new object storage connection details.

```shell
docker compose up -d
```