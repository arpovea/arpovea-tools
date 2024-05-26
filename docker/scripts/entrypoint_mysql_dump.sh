#!/bin/bash

set -eo pipefail

cat << 'EOF'
   _____ ____    _____  _    _ __  __ _____  
  / ____|___ \  |  __ \| |  | |  \/  |  __ \ 
 | (___   __) | | |  | | |  | | \  / | |__) |
  \___ \ |__ <  | |  | | |  | | |\/| |  ___/ 
  ____) |___) | | |__| | |__| | |  | | |     
 |_____/|____/  |_____/ \____/|_|  |_|_|     
                                            
EOF

echo "Iniciando backup de MySQL..."

# Validaciones de variables críticas
: "${DB_USER:?ERROR: Falta la variable de entorno DB_USER}"
: "${DB_PASS:?ERROR: Falta la variable de entorno DB_PASS}"
: "${DB_HOST:?ERROR: Falta la variable de entorno DB_HOST}"

# Variables de entorno y valores por defecto
BACKUP_STORAGE="${BACKUP_STORAGE:-/mysqldump}"
DATE_BACKUP=$(date +%Y%m%d%H%M)
DELETE_OLD_BACKUPS="${DELETE_OLD_BACKUPS:-false}"
MAX_BACKUP_DAYS="${MAX_BACKUP_DAYS:-7}"
FIND_MAX_DEPTH="${FIND_MAX_DEPTH:-2}"
MIN_MAX_DEPTH="${MIN_MAX_DEPTH:-1}"

# Ajuste de la ruta de almacenamiento de respaldo
BACKUP_STORAGE="${BACKUP_STORAGE}"
BACKUP_PATH="${BACKUP_STORAGE}/${DATE_BACKUP}"

# Creación de directorios de respaldo
echo "Preparando directorio de respaldo..."
mkdir -p "${BACKUP_PATH}"

echo -e "\nInformación del Sistema:"
df -h | grep "mysqldump"

echo -e "\nArbol de directorio de respaldo:"
tree -L 3 -T "Backup" "${BACKUP_STORAGE}"

# Realización de la copia de seguridad
if [[ "${ALL_DATABASES}" == "true" ]]; then
    echo -e "\nRealizando copia de seguridad de todas las bases de datos..."
    mysqldump -C --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" --all-databases | gzip > "${BACKUP_PATH}/all_databases.sql.gz" || exit 1
else
    echo -e "\nRealizando copia de seguridad de bases de datos específicas: $BACKUP_DATABASES"
    for db in $BACKUP_DATABASES; do
        mysqldump -C --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" --databases "$db" | gzip > "${BACKUP_PATH}/${db}.sql.gz" || exit 1
    done
fi

# Registro de checksums para validar integridad
find "${BACKUP_PATH}" -type f -print0 | xargs -0 sha1sum >> "${BACKUP_PATH}/checksums.txt"

echo -e "\nLista de respaldos:"
ls -lah "${BACKUP_PATH}"

echo -e "\nChecksums de respaldos:"
cat "${BACKUP_PATH}/checksums.txt"

# Limpieza de respaldos antiguos
if [[ "$DELETE_OLD_BACKUPS" == "true" ]]; then
    echo -e "\nLimpiando respaldos antiguos..."
    echo -e "Antes de la limpieza:"
    ls -lah "$BACKUP_STORAGE/"
    find "$BACKUP_STORAGE" -maxdepth "$FIND_MAX_DEPTH" -mindepth "$MIN_MAX_DEPTH" -type d -mtime +"$MAX_BACKUP_DAYS" -exec rm -rf {} +
    echo -e "Después de la limpieza:"
    ls -lah "$BACKUP_STORAGE/"
fi

echo "Backup de MySQL completado."
