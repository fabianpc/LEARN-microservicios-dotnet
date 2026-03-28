# Documentación para instalar SQLServer docker image

Bajar la imagen de https://hub.docker.com/r/microsoft/mssql-server

```shell
docker pull mcr.microsoft.com/mssql/server:2025-latest
```

Subir la imagen con los parametros

```shell
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=passwordSQL_PID=Evaluation" -p 1433:1433  --name sql2025 --network red-db -d mcr.microsoft.com/mssql/server:2025-latest
```

Para conectarse se emplea el usuario sa/password