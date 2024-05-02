[![License](https://img.shields.io/badge/License-MIT-blue)](https://github.com/arpovea/arpovea-tools/blob/main/LICENSE.md)
![Top Language](https://img.shields.io/github/languages/count/arpovea/arpovea-tools)
![Version](https://img.shields.io/badge/Version:-1.0-green)

# Arpovea-Tools

**Advertencia:** Este repositorio está actualmente en construcción. Las funcionalidades y configuraciones pueden cambiar.

**Arpovea-Tools** es una utilidad creada para entornos Kubernetes y OpenShift. Esta herramienta facilita la gestión y automatización de tareas de backups para las bases de datos mediante el uso de cronjobs y la copia de volúmenes persistentes (PVC). Además, facilita el despliegue de un pod a través de deployment que esta equipado con una serie de herramientas esenciales para el debugging y la administración de sistemas.

## Características Principales

- **Backups de Bases de Datos**: Automatiza backups para diversas bases de datos utilizando cronjobs configurables.
- **Copia de PVC**: Facilita la copia y el respaldo de volúmenes persistentes, asegurando la integridad de los datos en tu clúster.
- **Herramientas de Debugging**: Incluye un conjunto de herramientas de debugging dentro de los pods desplegados, permitiendo a los administradores de sistemas realizar diagnósticos y resolver problemas rápidamente.

# Estructura del Repositorio

Este repositorio contiene los siguientes componentes principales:

- **/helm-charts/**: Contiene el chart de Helm necesario para desplegar nuestras aplicación en entornos Kubernetes/OpenShift.
- **/docker/**: Almacena los Dockerfiles y otros recursos necesarios para construir las imágenes de Docker utilizadas por el chart de Helm.
- **/.github/workflows/**: Define nuestras pipelines de integración continua (CI) y entrega continua (CD) utilizando GitHub Actions.
- **/README.md** y **/LICENSE.md**: Proporcionan información general del proyecto y la licencia bajo la cual se distribuye.

Cada subdirectorio está adecuadamente documentado con un `README.md` propio que explica su propósito y uso.
