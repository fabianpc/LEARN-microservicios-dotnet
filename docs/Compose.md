# Documentación para Docker Compose

Crea un archivo **docker-compose.yml** dentro de tu carpeta de **microservicios**

```yml
  services:
    addmember:
      image: addmember
      build:
        context: ./AddMember
        dockerfile: Dockerfile
      ports:
        - 8080:8080
    pickage:
      image: pickage
      build:
        context: ./PickAge
        dockerfile: Dockerfile
    addadult:
      image: addadult
      build:
        context: ./AddAdult
        dockerfile: Dockerfile
    addchild:
      image: addchild
      build:
        context: ./AddChild
        dockerfile: Dockerfile
    getAdults:
      image: getadults
      build:
        context: ./GetAdults
        dockerfile: Dockerfile
      ports:
        - "5000:8080"
```

Crear la red para que se comuniquen los contenedores

```shell
docker network create red-db
```

¡Ejecuta Docker Compose!

```shell
docker compose up
```
Para utilizar la base de datos dentro de un contenedor se requiere cambiar localhost por el nombre del host en la red, adicionalmente se debe utilizar el parametro network en el comando de arranque, por ejemplo:

```shell
docker run -p 5000:8080  --name microservicios-getAdults-1 --network red-db -d getadults
```


