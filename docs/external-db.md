<h1 align="center">Connecting to an external database</h1>

> [!IMPORTANT]
> The platform only supports PostgreSQL databases with the following extensions
> installed and enabled:
>   - PostGIS
>   - TimescaleDB

## Disable the database container
To decrease the memory and processor consumption by the platform you can disable
the database container on your host while using an external platform.
The container will still be created but is changed to exit directly after
starting.

To apply this configuration, open or create a file called `compose.override.yml`
and insert the following content

```yml
services:
  db:
    command: ["/bin/true"]
    restart: no
```

## Change database dependency condition
Since Docker Compose now still expects the database container to run before the
other services can start, you now need to edit your configuration file to change
that behaviour.

Open the `wisdom.conf` file you created during the setup of the platform.
Uncomment the line containing the key `DATABASE_REQUIRED_STATE`.
This lets the services start after the database container exited successfully
(which has been configured in the previous step).

## Set and apply connection details

Afterwards, open your configuration file and configure the `DATABASE_*` to the
values the external database requires.

To apply the configuration to the running services and to disable the database
container run the following command which recreates all containers to allow them
to connect using the new database connection details.
```shell
docker compose up -d
```