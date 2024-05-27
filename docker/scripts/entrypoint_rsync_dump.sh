#!/bin/bash

set -eo pipefail

cat << 'EOF'
  .______          ___________    ____ .__   __.   ______ 
  |   _  \        /       \   \  /   / |  \ |  |  /      |
  |  |_)  |      |   (----`\   \/   /  |   \|  | |  ,----'
  |      /        \   \     \_    _/   |  . `  | |  |     
  |  |\  \----.----)   |      |  |     |  |\   | |  `----.
  | _| `._____|_______/       |__|     |__| \__|  \______|
          _______   __    __  .___  ___. .______        
         |       \ |  |  |  | |   \/   | |   _  \       
         |  .--.  ||  |  |  | |  \  /  | |  |_)  |      
         |  |  |  ||  |  |  | |  |\/|  | |   ___/       
         |  '--'  ||  `--'  | |  |  |  | |  |           
         |_______/  \______/  |__|  |__| | _|           
                                                            
EOF

echo "Iniciando backup RSYNC..."

# Variables ambientales requeridas
: "${BACKUP_STORAGE:?Variable BACKUP_STORAGE no definida}"
: "${ORIGIN_VOLUME:?Variable ORIGIN_VOLUME no definida}"

BACKUP_STORAGE_PREFIX="/rsyncdump"
DATE_BACKUP=$(date +%Y%m%d%H%M)
DELETE_OLD_BACKUPS=${DELETE_OLD_BACKUPS:-false}
MAX_BACKUP_DAYS=${MAX_BACKUP_DAYS:-7}
FIND_MAX_DEPTH=${FIND_MAX_DEPTH:-2}
MIN_MAX_DEPTH=${MIN_MAX_DEPTH:-1}

BACKUP_STORAGE="${BACKUP_STORAGE_PREFIX}/${BACKUP_STORAGE}"
BACKUP_PATH="${BACKUP_STORAGE}/${DATE_BACKUP}"

# Crear directorio de backup si no existe
mkdir -p "${BACKUP_STORAGE}"

#echo "Información del Sistema:"
#df -h | grep "rsyncdump\|rsyncori"

tree -L 3 -T "Origen" "/rsyncori"
echo -e "\n"
tree -L 3 -T "Backup" "${BACKUP_STORAGE}"

# Verificar y crear directorio de trabajo
if [ -d "${BACKUP_PATH}" ]; then
  echo "ERROR: El directorio ${BACKUP_PATH} ya existe."
  exit 1
fi

echo "Creando directorio de trabajo ${BACKUP_PATH}"
mkdir -p "${BACKUP_PATH}"
ls -lah "${BACKUP_PATH}"

echo "Lanzando RSYNC..."
rsync -axHA "${ORIGIN_VOLUME}/" "${BACKUP_PATH}/temp/" || exit 1

echo "Lista de salida Rsync:"
ls -lah "${BACKUP_PATH}/temp/"

# Comprimir y limpiar
(
  cd "${BACKUP_PATH}/temp"
  tar -czf "../backup_${DATE_BACKUP}.tar.gz" .
)
rm -rf "${BACKUP_PATH}/temp"

echo -e "\nLista de Backups:"
ls -lah "${BACKUP_PATH}"

echo "Checksum del backup:"
sha1sum "${BACKUP_PATH}/backup_${DATE_BACKUP}.tar.gz" | tee "${BACKUP_PATH}/checksums.txt"

# Limpieza de backups antiguos
if [[ "$DELETE_OLD_BACKUPS" == "true" ]]; then
  echo -e "\nLimpiando backups del directorio ${BACKUP_STORAGE} con antigüedad superior a ${MAX_BACKUP_DAYS} días"
  echo -e "\nAntes de la limpieza:"
  ls -lah "${BACKUP_STORAGE}/"
  find "${BACKUP_STORAGE}" -maxdepth "$FIND_MAX_DEPTH" -mindepth "$MIN_MAX_DEPTH" -type d -mtime +"$MAX_BACKUP_DAYS" -exec rm -rf {} +
  echo -e "\nDespués de la limpieza:"
  ls -lah "${BACKUP_STORAGE}/"
fi

echo "Backup completo."
