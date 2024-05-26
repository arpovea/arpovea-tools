#!/bin/bash

set -eo pipefail

cat << 'EOF'
.______      _______  _______   __       _______.
|   _  \    |   ____||       \ |  |     /       |
|  |_)  |   |  |__   |  .--.  ||  |    |   (----`
|      /    |   __|  |  |  |  ||  |     \   \    
|  |\  \----|  |____ |  '--'  ||  | .----)   |   
| _| `._____|_______||_______/ |__| |_______/    
    _______   __    __  .___  ___. .______       
   |       \ |  |  |  | |   \/   | |   _  \      
   |  .--.  ||  |  |  | |  \  /  | |  |_)  |     
   |  |  |  ||  |  |  | |  |\/|  | |   ___/      
   |  '--'  ||  `--'  | |  |  |  | |  |          
   |_______/  \______/  |__|  |__| | _|          
                                                 
EOF

echo "Iniciando backup de Redis..."

# Validaciones de variables críticas
: "${DB_PASS:?ERROR: Falta la variable de entorno DB_PASS}"
: "${DB_HOST:?ERROR: Falta la variable de entorno DB_HOST}"

# Variables de entorno y valores por defecto
DB_PORT="${DB_PORT:-6379}"
RDB_FILE="${RDB_FILE:-dump.rdb}"
BACKUP_STORAGE="${BACKUP_STORAGE:-/redisdump}"
DATE_BACKUP=$(date +%Y%m%d%H%M)
DELETE_OLD_BACKUPS="${DELETE_OLD_BACKUPS:-false}"
MAX_BACKUP_DAYS="${MAX_BACKUP_DAYS:-7}"
FIND_MAX_DEPTH="${FIND_MAX_DEPTH:-2}"
MIN_MAX_DEPTH="${MIN_MAX_DEPTH:-1}"
WAIT_SAVE_RDB="${WAIT_SAVE_RDB:-30}"

# Ajuste de la ruta de almacenamiento de respaldo
BACKUP_STORAGE="${BACKUP_STORAGE}"
BACKUP_PATH="${BACKUP_STORAGE}/${DATE_BACKUP}"

# Creación de directorios de respaldo
echo "Preparando directorio de respaldo..."
mkdir -p "${BACKUP_PATH}"

echo -e "\nInformación del Sistema:"
df -h | grep "redisdump"

echo -e "\nArbol de directorio de respaldo:"
tree -L 3 -T "Backup" "${BACKUP_STORAGE}"

# Realización de la copia de seguridad
echo -e "\nTesting Redis connection:"
redis-cli -h "${DB_HOST}" -p "${DB_PORT}" -a "${DB_PASS}" ping || exit 1

echo -e "\nForce dump cache to file and wait ${WAIT_SAVE_RDB} sec:"
redis-cli -h "${DB_HOST}" -p "${DB_PORT}" -a "${DB_PASS}" save || exit 1
sleep "${WAIT_SAVE_RDB}"

echo -e "\nDownload ${RDB_FILE}:"
cd "${BACKUP_PATH}/"
redis-cli -h "${DB_HOST}" -p "${DB_PORT}" -a "${DB_PASS}" --rdb "${RDB_FILE}" || exit 1

find "${BACKUP_PATH}" -type f -print0 | xargs -0 sha1sum >> "${BACKUP_PATH}/checksums.txt"

echo -e "\nLista de respaldos:"
ls -lah "${BACKUP_PATH}"

echo -e "\nChecksums de respaldos:"
cat "${BACKUP_PATH}/checksums.txt"

# Limpieza de respaldos antiguos
if [[ "$DELETE_OLD_BACKUPS" == "true" ]]; then
    echo -e "\nLimpiando respaldos antiguos..."
    echo -e "Antes de la limpieza:"
    ls -lah "${BACKUP_STORAGE}/"
    find "${BACKUP_STORAGE}" -maxdepth "$FIND_MAX_DEPTH" -mindepth "$MIN_MAX_DEPTH" -type d -mtime +"$MAX_BACKUP_DAYS" -exec rm -rf {} +
    echo -e "Después de la limpieza:"
    ls -lah "${BACKUP_STORAGE}/"
fi

echo "Backup de Redis completado."
