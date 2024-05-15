#!/bin/bash

set -eo pipefail

cat << 'EOF'
.______     _______      _______.  ______      __      
|   _  \   /  _____|    /       | /  __  \    |  |     
|  |_)  | |  |  __     |   (----`|  |  |  |   |  |     
|   ___/  |  | |_ |     \   \    |  |  |  |   |  |     
|  |      |  |__| | .----)   |   |  `--'  '--.|  `----.
| _|       \______| |_______/     \_____\_____\_______|                                                    
 _______   __    __  .___  ___. .______                
|       \ |  |  |  | |   \/   | |   _  \               
|  .--.  ||  |  |  | |  \  /  | |  |_)  |              
|  |  |  ||  |  |  | |  |\/|  | |   ___/               
|  '--'  ||  `--'  | |  |  |  | |  |                   
|_______/  \______/  |__|  |__| | _|                   

EOF

echo "Iniciando backup de PostgreSQL..."

# Validaciones de variables críticas
: "${DB_USER:?ERROR: Falta la variable de entorno DB_USER}"
: "${DB_PASS:?ERROR: Falta la variable de entorno DB_PASS}"
: "${DB_HOST:?ERROR: Falta la variable de entorno DB_HOST}"
: "${BACKUP_STORAGE:?ERROR: Falta la variable de entorno BACKUP_STORAGE}"

# Variables de entorno y valores por defecto
DB_PORT="${DB_PORT:-5432}"
BACKUP_DATABASES="${BACKUP_DATABASES:-mydatabase}"
DATE_BACKUP=$(date +%Y%m%d%H%M)
DELETE_OLD_BACKUPS="${DELETE_OLD_BACKUPS:-false}"
MAX_BACKUP_DAYS="${MAX_BACKUP_DAYS:-7}"
FIND_MAX_DEPTH="${FIND_MAX_DEPTH:-2}"
MIN_MAX_DEPTH="${MIN_MAX_DEPTH:-1}"

# Ajuste de la ruta de almacenamiento de respaldo
BACKUP_STORAGE="/pgdump/${BACKUP_STORAGE}"
BACKUP_PATH="${BACKUP_STORAGE}/${DATE_BACKUP}"

# Creación de directorios de respaldo
echo "Preparando directorio de respaldo..."
mkdir -p "${BACKUP_PATH}"

echo -e "\nInformación del Sistema:"
df -h | grep "pgdump"

echo -e "\nArbol de directorio de respaldo:"
tree -L 3 -T "Backup" "${BACKUP_STORAGE}"

# Realización de la copia de seguridad
echo -e "\nRealizando copia de seguridad de bases de datos específicas..."
export PGPASSWORD="${DB_PASS}"
for db in $BACKUP_DATABASES; do
    echo -e "\t- Dumping database: $db"
    pg_dump -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${db}" -b -v -f "${BACKUP_PATH}/${db}.bak" || exit 1
    sha1sum "${BACKUP_PATH}/${db}.bak" >> "${BACKUP_PATH}/checksums.txt"
done

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

echo "Backup de PostgreSQL completado."
