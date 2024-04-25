#!/bin/bash

set -eo pipefail

echo "   _____ ____    _____  _    _ __  __ _____  "
echo "  / ____|___ \  |  __ \| |  | |  \/  |  __ \ "
echo " | (___   __) | | |  | | |  | | \  / | |__) |"
echo "  \___ \ |__ <  | |  | | |  | | |\/| |  ___/ "
echo "  ____) |___) | | |__| | |__| | |  | | |     "
echo " |_____/|____/  |_____/ \____/|_|  |_|_|     "
echo "                                             "
echo -e "\nComenzando copia de seguridad de MINIO"

# Variables ambientales requeridas
: "${ENDPOINT:?Variable ENDPOINT no definida}"
: "${USERMINIO:?Variable USERMINIO no definida}"
: "${PASSWORDMINIO:?Variable PASSWORDMINIO no definida}"
: "${PATH_BACKUP:?Variable PATH_BACKUP no definida}"

PATH_COMPRESS="${PATH_COMPRESS:-s3minio}"
MAX_BACKUP_DAYS="${MAX_BACKUP_DAYS:-7}"
DELETE_OLD_BACKUPS="${DELETE_OLD_BACKUPS:-false}"
DATE_BACKUP=$(date +%Y%m%d)
export RCLONE_CONFIG="/tmp/rclone.conf"

cat > "$RCLONE_CONFIG" << EOF
[minio]
type = s3
provider = Minio
access_key_id = $USERMINIO
secret_access_key = $PASSWORDMINIO
endpoint = $ENDPOINT
EOF

for BUCKET in $(rclone lsf minio:); do
    echo -e "\nCopiando/sincronizando ficheros de: $BUCKET"
    rclone copy "minio:$BUCKET" "$PATH_BACKUP/$PATH_COMPRESS/$BUCKET"
done

echo -e "\nComprimiendo..."
cd "$PATH_BACKUP/$PATH_COMPRESS"
tar -czf "$DATE_BACKUP.tar.gz" * --remove-files
mv "$DATE_BACKUP.tar.gz" "$PATH_BACKUP"

if [[ "$DELETE_OLD_BACKUPS" = true ]]; then
    echo -e "\nLimpiando backups del directorio $PATH_BACKUP con antigüedad superior a $MAX_BACKUP_DAYS días"
    ls -lah "$PATH_BACKUP/"
    find "$PATH_BACKUP/" -type f -mtime "+$MAX_BACKUP_DAYS" -exec rm -rf {} +
    echo -e "\nDespués de la limpieza:"
    ls -lah "$PATH_BACKUP/"
fi

rm -rf "$PATH_BACKUP/$PATH_COMPRESS"
rm -f "$RCLONE_CONFIG"

echo -e "\nFinalizado con éxito."
