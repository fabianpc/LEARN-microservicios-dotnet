# Instalacion de .NET8 en Debian 12 

La instalación con APT puede realizarse con unos pocos comandos. Antes de instalar .NET, ejecute los siguientes comandos para agregar la clave de firma del paquete de Microsoft a la lista de claves de confianza y agregar el repositorio de paquetes. Abra un terminal y ejecute los comandos siguientes:

```bash
wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
```

## Instalación del SDK .NET8

El SDK de .NET permite desarrollar aplicaciones con .NET. Si instala el SDK de .NET, no es necesario instalar el entorno de ejecución correspondiente. Para instalar el SDK de .NET, ejecute los siguientes comandos:

```bash
sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-8.0
```

---
Recursos:

https://learn.microsoft.com/es-es/dotnet/core/install/linux-debian?tabs=dotnet8
