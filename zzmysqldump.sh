#!/usr/bin/env bash

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "📦 zzmysqldump"

fxConfigLoader "$1"


fxTitle "🔌 Connecting..."
if [ ! -z "$MYSQL_PASSWORD" ]; then
  MYSQL_PASSWORD_HIDDEN="${MYSQL_PASSWORD:0:2}**...**${MYSQL_PASSWORD: -2}"
fi  
    
echo "👤 User: ##${MYSQL_USER}##"
echo "🔑 Pass: ##${MYSQL_PASSWORD_HIDDEN}##"
echo "🖥️ Host: ##${MYSQL_HOST}##"
echo ""

DATABASES=$(mysql -N -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -e 'show databases')
if [ $? -eq 0 ]; then
  fxMessage "$DATABASES"
else
  fxCatastrophicError "Database connection failed"
fi


fxTitle "📂 Creating the backup directory..."
MYSQL_BACKUP_DIR="${MYSQL_BACKUP_DIR%/}/"
fxInfo "The backup directory is ##${MYSQL_BACKUP_DIR}##"
mkdir -p "${MYSQL_BACKUP_DIR}"
touch "${MYSQL_BACKUP_DIR}⚠️ WARNING! This folder is auto-cleaned periodically!"


fxTitle "🚫 Applying exclude filter..."
if [ ! -z "$MYSQL_DB_EXCLUDE" ]; then

  DATABASES=$(echo "$DATABASES" | egrep -vx "$MYSQL_DB_EXCLUDE")
  fxMessage "$DATABASES"
  
else

  fxInfo "No exclude filter defined. I'm going to backup every database"
fi


fxTitle "💚 Applying include filter.."
if [ ! -z "$MYSQL_DB_INCLUDE" ]; then

  DATABASES=$(echo "$DATABASES" | egrep -x "$MYSQL_DB_INCLUDE")
  fxMessage "$DATABASES"

else

  fxInfo "No include filter defined."
fi


## Set and clean the 7zip log for non-blocking mode
fxTitle "💨 Check if 7-Zip should run in non-blocking mode..."
if [ "${SEVENZIP_NON_BLOCKING}" = 1 ]; then

  fxMessage "7-Zip NON-BLOCKING mode enabled"
  SEVENZIP_NON_BLOCKING_LOGFILE_SUFFIX=_background_7zipping.log
  ## remove leftovers
  rm -f "${MYSQL_BACKUP_DIR}"*${SEVENZIP_NON_BLOCKING_LOGFILE_SUFFIX}

else

  fxInfo "7-Zip will run is blocking mode"
fi


## Iterate over DBs
for DATABASE in $DATABASES; do

  ## Dump filename
  DUMPFILE_FULLPATH=${MYSQL_BACKUP_DIR}${HOSTNAME}_${DATABASE}_${DOWEEK}.sql
  
  fxTitle "📦 mysqldumping ##${DATABASE}##"
  fxMessage "$DUMPFILE_FULLPATH"
  mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" $MYSQLDUMP_OPTIONS --databases "$DATABASE" > "$DUMPFILE_FULLPATH"
  
  fxTitle "🧪 Optimizing the exported file..."
  ## autocommit optimization - header
  NO_AUTOCOMMIT_TEXT="SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, AUTOCOMMIT=0;"
  sed -i "/Server version/ a ${NO_AUTOCOMMIT_TEXT}" "$DUMPFILE_FULLPATH"
  ## autocommit optimization - footer
  echo "COMMIT;" >> "$DUMPFILE_FULLPATH"
  echo "SET AUTOCOMMIT=@OLD_AUTOCOMMIT" >> "$DUMPFILE_FULLPATH"

  fxTitle "🗜 7-zipping ##${DATABASE}##"
  rm -f "${DUMPFILE_FULLPATH}.7z"

  if [ ${SEVENZIP_NON_BLOCKING} == 1 ]; then
    bash "${SCRIPT_DIR}7zip-log-to-file.sh" "${SEVENZIP_COMPRESS_OPTIONS}" "${DUMPFILE_FULLPATH}.7z" "${DUMPFILE_FULLPATH}" "${DUMPFILE_FULLPATH}${SEVENZIP_NON_BLOCKING_LOGFILE_SUFFIX}" &
  else
    7za a ${SEVENZIP_COMPRESS_OPTIONS} "${DUMPFILE_FULLPATH}.7z" "${DUMPFILE_FULLPATH}"
  fi
  
done


fxTitle "Deleting old files..."
if [ -z "$1" ]; then

  fxMessage "Current retention: ##${RETENTION_DAYS}## day(s)"
  find "${MYSQL_BACKUP_DIR}" -type f -mtime +${RETENTION_DAYS} \( -name "*.sql.7z" -o -name "*.sql" -o -name "*.log" \)
  find "${MYSQL_BACKUP_DIR}" -type f -mtime +${RETENTION_DAYS} \( -name "*.sql.7z" -o -name "*.sql" -o -name "*.log" \) -delete
  
else

  fxInfo "Skipping when running with a profile"
fi


fxTitle "Backup file list"
ls -latrh "${MYSQL_BACKUP_DIR}"


fxEndFooter
