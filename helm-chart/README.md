
# Backup Cronjobs Helm Chart

**Advertencia:** Este repositorio está actualmente en construcción. Las funcionalidades y configuraciones pueden cambiar.

Este chart de Helm está diseñado para facilitar la creación y manejo de cronjobs de backup para diferentes sistemas de gestión de bases de datos como PostgreSQL, MongoDB, MySQL, y MinIO en un entorno Kubernetes.

## Descripción

Este chart incluye todo lo necesario para configurar cronjobs automáticos que ejecutan backups de bases de datos utilizando herramientas como `pgdump`, `mongodump`, `mysqldump`, y scripts personalizados para MinIO. Cada cronjob puede ser configurado individualmente a través de valores en el archivo `values.yaml`.

## Pre-requisitos

- Kubernetes 1.12+
- Helm 3.0+
- Acceso adecuado a un registro de imágenes que contenga las imágenes de utilidades necesarias para los backups.

## Configuración

El chart permite una configuración detallada para cada tipo de backup. Los parámetros configurables incluyen:
- Intervalos de cron para la ejecución de los jobs.
- Recursos asignados a cada job.
- Configuración de conexiones a bases de datos.
- Gestión de almacenamiento de backups a través de PVCs.

## Instalación

Para instalar el chart con el nombre de lanzamiento `my-backup`, ejecuta:

```bash
helm install my-backup ./path-to-chart
```

## Configuración Detallada

### Parámetros Generales

- `global.serviceSelector`: Permite activar o desactivar específicamente los cronjobs para cada base de datos.

### Parámetros Específicos

Cada cronjob tiene configuraciones que pueden ser ajustadas en el `values.yaml`. A continuación se muestra la estructura general para cada tipo:

```yaml
pgsql:
  enabled: true
  serviceName: pgdump
  imageTag: "1.0.2"
  reqMemory: "100Mi"
  reqCpu: "100m"
  pvcBackupName: "backups"
  cronTime: "0 3 * * *"
  ...
```

### Actualizaciones

Para actualizar tu despliegue después de ajustar el `values.yaml`, ejecuta:

```bash
helm upgrade my-backup ./path-to-chart
```

## Desinstalación

Para eliminar el despliegue, utiliza:

```bash
helm uninstall my-backup
```

## Parameters

### General Parameters

| Parameter                   | Description                                   | Default                  |
|-----------------------------|-----------------------------------------------|--------------------------|
| `global.serviceSelector`    | Servicios para activar.                       | `See values.yaml`        |
| `global.registry`           | Registro Docker para imágenes.                | `"docker.io"`            |
| `global.image`              | Imagen del contenedor.                        | `"arpovea/arpovea-tools"`|
| `global.imageTag`           | Etiqueta de la imagen.                        | `"1.0"`                  |
| `openshift.createBuildConfig` | Si se debe crear un BuildConfig en OpenShift | `false`                  |

### Testing Parameters

| Parameter                   | Description                                   | Default                  |
|-----------------------------|-----------------------------------------------|--------------------------|
| `testing.serviceName`       | Nombre del servicio de pruebas.               | `"testing-service"`      |
| `testing.replicas`          | Número de replicas para el servicio de pruebas| `1`                      |
| `testing.image.pullPolicy`  | Política de obtención de la imagen.           | `"IfNotPresent"`         |
| `testing.resources`         | Recursos CPU/Memoria solicitados y límites.   | `See values.yaml`        |

### MinIO Backup Parameters

| Parameter                         | Description                                                  | Default               |
|-----------------------------------|--------------------------------------------------------------|-----------------------|
| `minio.serviceName`               | Nombre del servicio para el cronjob de MinIO.                | `miniodump`           |
| `minio.resources.requests.cpu`    | CPU solicitada para el cronjob de MinIO.                     | `100m`                |
| `minio.resources.requests.memory` | Memoria solicitada para el cronjob de MinIO.                 | `128Mi`               |
| `minio.resources.limits.cpu`      | Límite de CPU para el cronjob de MinIO.                      | `200m`                |
| `minio.resources.limits.memory`   | Límite de memoria para el cronjob de MinIO.                  | `256Mi`               |
| `minio.endpoint`                  | Endpoint para acceder a MinIO.                               | `http://minio.minio:9000` |
| `minio.existingSecret`            | Nombre del secret existente que contiene las credenciales.   | `""`                  |
| `minio.user`                      | Usuario de MinIO utilizado para autenticación.               | `dummyuser`         |
| `minio.password`                  | Contraseña de MinIO utilizada para autenticación.            | `dummypass`     |
| `minio.pvcBackupName`             | Nombre del PVC donde se almacenan los backups.               | `backups`             |
| `minio.cronTime`                  | Cronograma para la ejecución del cronjob.                    | `0 3 * * *`           |
| `minio.pathBackup`                | Ruta en el PVC donde se almacenan los backups.               | `/miniodump`          |
| `minio.pathCompress`              | Ruta relativa donde se almacenan temporalmente los archivos antes de comprimir. | `s3minio` |
| `minio.deleteOldBackups`          | Si se deben eliminar los backups antiguos.                   | `false`               |
| `minio.maxBackupDays`             | Número de días después de los cuales los backups antiguos deben ser eliminados. | `7`                   |

### MySQL Backup Parameters

| Parameter                      | Description                                                      | Default                     |
|--------------------------------|------------------------------------------------------------------|-----------------------------|
| `mysql.serviceName`            | Nombre del servicio para el cronjob de MySQL.                    | `mysqldump`                 |
| `mysql.resources.requests.cpu` | CPU solicitada para el cronjob de MySQL.                         | `100m`                      |
| `mysql.resources.requests.memory` | Memoria solicitada para el cronjob de MySQL.                   | `128Mi`                     |
| `mysql.resources.limits.cpu`   | Límite de CPU para el cronjob de MySQL.                          | `200m`                      |
| `mysql.resources.limits.memory` | Límite de memoria para el cronjob de MySQL.                     | `256Mi`                     |
| `mysql.pvcBackupName`          | Nombre del PVC donde se almacenan los backups.                   | `backups`                   |
| `mysql.cronTime`               | Cronograma para la ejecución del cronjob.                        | `*/5 * * * *`               |
| `mysql.allDatabases`           | Si se debe hacer backup de todas las bases de datos.             | `false`                     |
| `mysql.backupDatabases`        | Lista de bases de datos específicas para hacer backup.           | `"basededatos1 basededatos2 sampledb"` |
| `mysql.backupStorage`          | Ubicación de almacenamiento de los backups.                      | `"exampleapp1"`            |
| `mysql.existingSecret`         | Nombre del secret existente que contiene las credenciales.       | `""`                        |
| `mysql.dbHost`                 | Host de la base de datos.                                         | `"mysql"`                   |
| `mysql.dbUser`                 | Usuario de la base de datos.                                      | `"dummyuser"`                    |
| `mysql.dbPass`                 | Contraseña de la base de datos.                                   | `"dummypass"`            |
| `mysql.deleteOldBackups`       | Si se deben eliminar los backups antiguos.                       | `false`                     |
| `mysql.maxBackupDays`          | Número de días después de los cuales los backups antiguos deben ser eliminados. | `7`       |

### MongoDB Backup Parameters

| Parameter                          | Description                                                      | Default                    |
|------------------------------------|------------------------------------------------------------------|----------------------------|
| `mongo.serviceName`                | Nombre del servicio para el cronjob de MongoDB.                  | `mongodump`                |
| `mongo.resources.requests.cpu`     | CPU solicitada para el cronjob de MongoDB.                       | `100m`                     |
| `mongo.resources.requests.memory`  | Memoria solicitada para el cronjob de MongoDB.                   | `128Mi`                    |
| `mongo.resources.limits.cpu`       | Límite de CPU para el cronjob de MongoDB.                        | `200m`                     |
| `mongo.resources.limits.memory`    | Límite de memoria para el cronjob de MongoDB.                    | `256Mi`                    |
| `mongo.pvcBackupName`              | Nombre del PVC donde se almacenan los backups de MongoDB.        | `backups`                  |
| `mongo.cronTime`                   | Cronograma para la ejecución del cronjob.                        | `*/5 * * * *`              |
| `mongo.allDatabases`               | Si se debe hacer backup de todas las bases de datos MongoDB.     | `false`                    |
| `mongo.backupDatabases`            | Lista de bases de datos específicas de MongoDB para hacer backup.| `"basededatos1 basededatos2 sampledb"` |
| `mongo.backupStorage`              | Ubicación de almacenamiento de los backups de MongoDB.           | `"exampleapp1"`            |
| `mongo.existingSecret`             | Nombre del secret existente que contiene las credenciales de MongoDB. | `""`                  |
| `mongo.dbHost`                     | Host de la base de datos MongoDB.                                | `"mongodb"`                |
| `mongo.dbUser`                     | Usuario de la base de datos MongoDB.                             | `"dummyuser"`                  |
| `mongo.dbPass`                     | Contraseña de la base de datos MongoDB.                          | `"dummypass"`            |
| `mongo.deleteOldBackups`           | Si se deben eliminar los backups antiguos de MongoDB.            | `false`                    |
| `mongo.maxBackupDays`              | Número de días después de los cuales los backups antiguos deben ser eliminados. | `7` |

### PostgreSQL Backup Parameters

| Parameter                          | Description                                                        | Default                     |
|------------------------------------|--------------------------------------------------------------------|-----------------------------|
| `pgsql.serviceName`                | Nombre del servicio para el cronjob de PostgreSQL.                 | `pgdump`                    |
| `pgsql.resources.requests.cpu`     | CPU solicitada para el cronjob de PostgreSQL.                      | `100m`                      |
| `pgsql.resources.requests.memory`  | Memoria solicitada para el cronjob de PostgreSQL.                  | `128Mi`                     |
| `pgsql.resources.limits.cpu`       | Límite de CPU para el cronjob de PostgreSQL.                       | `200m`                      |
| `pgsql.resources.limits.memory`    | Límite de memoria para el cronjob de PostgreSQL.                   | `256Mi`                     |
| `pgsql.pvcBackupName`              | Nombre del PVC donde se almacenan los backups de PostgreSQL.       | `backups`                   |
| `pgsql.cronTime`                   | Cronograma para la ejecución del cronjob.                          | `*/5 * * * *`               |
| `pgsql.backupDatabases`            | Lista de bases de datos específicas de PostgreSQL para hacer backup. | `"basededatos1 basededatos2 sampledb"` |
| `pgsql.backupStorage`              | Ubicación de almacenamiento de los backups de PostgreSQL.          | `"exampleapp1"`             |
| `pgsql.existingSecret`             | Nombre del secret existente que contiene las credenciales de PostgreSQL. | `""`                     |
| `pgsql.dbHost`                     | Host de la base de datos PostgreSQL.                               | `"postgresql"`              |
| `pgsql.dbUser`                     | Usuario de la base de datos PostgreSQL.                            | `"dummyuser"`                    |
| `pgsql.dbPass`                     | Contraseña de la base de datos PostgreSQL.                         | `"dummypass"`             |
| `pgsql.deleteOldBackups`           | Si se deben eliminar los backups antiguos de PostgreSQL.           | `false`                     |
| `pgsql.maxBackupDays`              | Número de días después de los cuales los backups antiguos deben ser eliminados. | `7`                  |

### Redis Backup Parameters

| Parameter                         | Description                                                      | Default                     |
|-----------------------------------|------------------------------------------------------------------|-----------------------------|
| `redis.serviceName`               | Nombre del servicio para el cronjob de Redis.                    | `redisdump`                 |
| `redis.resources.requests.cpu`    | CPU solicitada para el cronjob de Redis.                         | `100m`                      |
| `redis.resources.requests.memory` | Memoria solicitada para el cronjob de Redis.                     | `128Mi`                     |
| `redis.resources.limits.cpu`      | Límite de CPU para el cronjob de Redis.                          | `200m`                      |
| `redis.resources.limits.memory`   | Límite de memoria para el cronjob de Redis.                      | `256Mi`                     |
| `redis.pvcBackupName`             | Nombre del PVC donde se almacenan los backups de Redis.          | `backups`                   |
| `redis.cronTime`                  | Cronograma para la ejecución del cronjob.                        | `*/5 * * * *`               |
| `redis.backupStorage`             | Ubicación de almacenamiento de los backups de Redis.             | `exampleapp`                |
| `redis.existingSecret`            | Nombre del secret existente que contiene las credenciales de Redis. | `""`                     |
| `redis.dbHost`                    | Host de la base de datos Redis.                                  | `redis`                     |
| `redis.dbUser`                    | Usuario de la base de datos Redis.                               | `dummyuser`                      |
| `redis.dbPass`                    | Contraseña de la base de datos Redis.                            | `dummypass`               |
| `redis.dbPort`                    | Puerto de la base de datos Redis.                                | `6379`                      |
| `redis.waitSaveRdb`               | Tiempo de espera para guardar el archivo RDB de Redis.           | `30`                        |
| `redis.deleteOldBackups`          | Si se deben eliminar los backups antiguos de Redis.              | `true`                      |
| `redis.maxBackupDays`             | Número de días después de los cuales los backups antiguos deben ser eliminados. | `7`                  |

### Rsync Backup Parameters

| Parameter                          | Description                                                         | Default                  |
|------------------------------------|---------------------------------------------------------------------|--------------------------|
| `rsync.serviceName`                | Nombre del servicio para el cronjob de Rsync.                       | `rsyncdump`              |
| `rsync.resources.requests.cpu`     | CPU solicitada para el cronjob de Rsync.                            | `100m`                   |
| `rsync.resources.requests.memory`  | Memoria solicitada para el cronjob de Rsync.                        | `128Mi`                  |
| `rsync.resources.limits.cpu`       | Límite de CPU para el cronjob de Rsync.                             | `200m`                   |
| `rsync.resources.limits.memory`    | Límite de memoria para el cronjob de Rsync.                         | `256Mi`                  |
| `rsync.pvcBackupName`              | Nombre del PVC donde se almacenan los backups de Rsync.             | `backups`                |
| `rsync.pvcOriginName`              | Nombre del PVC de origen de datos para Rsync.                       | `pvc-origin`             |
| `rsync.cronTime`                   | Cronograma para la ejecución del cronjob.                           | `*/5 * * * *`            |
| `rsync.backupStorage`              | Ubicación de almacenamiento de los backups de Rsync.                | `exampleapp1`            |
| `rsync.deleteOldBackups`           | Si se deben eliminar los backups antiguos de Rsync.                 | `false`                  |
| `rsync.maxBackupDays`              | Número de días después de los cuales los backups antiguos deben ser eliminados. | `7`       |

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo `LICENSE.md` para más detalles.