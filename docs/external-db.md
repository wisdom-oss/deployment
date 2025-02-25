<h1 align="center">Connecting to an external database</h1>

To connect an external database to the platform please ensure that the
PostgreSQL database is running the follwoing extensions as they are required by
the services in the platform:
  * PostGIS
  * TimescaleDB

After validating that the database has those extenstions and they are enabled
in the database you are connecting to create a file called 
`compose.override.yml` which overrides the other compose files and add the
following content:

```yaml
services:
  db:
    restart: no
    command: ["/bin/true"]
```
This reconfiguration of the database container ensures that the configuration
stays valid, while not starting up the PostgreSQL processes and therefore
saving memory and reducing processor utilization.

To apply the configuration to the running services and to disable the database
container run the following command which recreates all containers to allow them
to connect using the new database connection details.
```shell
docker compose up -d
```