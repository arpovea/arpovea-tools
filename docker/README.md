# Arpovea Tools Docker Image

Esta imagen de Docker está basada en Debian Bookworm Slim y proporciona un conjunto de herramientas y utilidades comúnmente utilizadas para tareas de administración del sistema, desarrollo y mantenimiento. 

## Contenido de la Imagen

La imagen contiene las siguientes herramientas y utilidades preinstaladas:

- **busybox**: Proporciona una colección de utilidades Unix en un solo ejecutable.
- **curl**: Utilidad para transferir datos desde o hacia un servidor.
- **git**: Sistema de control de versiones distribuido.
- **gnupg**: Software para cifrado y firmas digitales.
- **htop**: Monitor interactivo de procesos para Unix.
- **iperf**: Herramienta de prueba de ancho de banda de red.
- **iputils-ping**: Herramientas de red para enviar paquetes de prueba y diagnósticos.
- **iputils-tracepath**: Herramienta para rastrear la ruta de los paquetes de red.
- **jq**: Procesador de JSON ligero y flexible.
- **mariadb-client**: Cliente de base de datos MariaDB.
- **net-tools**: Conjunto de herramientas de red.
- **nfs-common**: Soporte para sistemas de archivos de red NFS.
- **nmap**: Herramienta de escaneo y auditoría de red.
- **openssl**: Herramienta de criptografía.
- **postgresql-client**: Cliente de base de datos PostgreSQL.
- **redis-tools**: Herramientas de cliente para Redis.
- **rsync**: Herramienta para sincronización y copia de archivos.
- **strace**: Herramienta de depuración de llamadas al sistema.
- **sudo**: Permite a un usuario ejecutar programas con los privilegios de otro usuario.
- **tcpdump**: Captura y analiza paquetes de red.
- **tree**: Muestra el contenido de un directorio en forma de árbol.
- **unzip**: Utilidad para descomprimir archivos.
- **vim**: Editor de texto avanzado.
- **wget**: Herramienta de descarga de archivos desde la web.
- **zip**: Herramienta de compresión de archivos.
- **mongodb-database-tools**: Herramientas de base de datos de MongoDB.
- **mongodb-mongosh**: Shell de MongoDB.
- **rclone**: Herramienta de sincronización de archivos en la nube.

## Instalación y Uso

### Construir la Imagen

Para construir la imagen de Docker, navega al directorio que contiene tu Dockerfile y ejecuta el siguiente comando:

```bash
docker build -t arpovea-tools .
```

### Ejecutar la Imagen

Para ejecutar un contenedor usando la imagen construida:

```
docker run -it --rm arpovea-tools
```

### Scripts Personalizados

La imagen incluye varios scripts personalizados ubicados en el directorio scripts/. Estos scripts se copian al directorio /bin/ dentro de la imagen de Docker y se ajustan los permisos para asegurar su compatibilidad con entornos Openshift.