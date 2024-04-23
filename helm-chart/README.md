
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

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo `LICENSE.md` para más detalles.