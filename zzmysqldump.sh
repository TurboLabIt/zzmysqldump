#!/usr/bin/env bash
echo ""

## Script name
SCRIPT_NAME=zzmysqldump

source "/usr/local/turbolab.it/zzmysqldump/base.sh"

## Dump profile requested
if [ ! -z "$1" ]; then
  zzmysqldumpProfileConfigSet "$1"
fi

## Retrive databases list and test connection
listDatabases

## Create backup directory
echo ""
echo "Creating backup directory"
echo "-------------------------"
echo "${MYSQL_BACKUP_DIR}"
mkdir -p "${MYSQL_BACKUP_DIR}"
touch "${MYSQL_BACKUP_DIR}WARNING! ⚠️ This folder gets cleaned periodically ⚠️"

## Exclude filter
if [ ! -z "$MYSQL_DB_EXCLUDE" ]; then

  echo ""
  echo "Applying exclude filter"
  echo "-----------------------"
  DATABASES=$(echo "$DATABASES" | egrep -vx "$MYSQL_DB_EXCLUDE")
  echo $DATABASES

fi

## Include filter
if [ ! -z "$MYSQL_DB_INCLUDE" ]; then

  echo ""
  echo "Applying include filter"
  echo "-----------------------"
  DATABASES=$(echo "$DATABASES" | egrep -x "$MYSQL_DB_INCLUDE")
  echo $DATABASES

fi

## Set and clean the 7zip log for non-blocking mode
if [ ${SEVENZIP_NON_BLOCKING} == 1 ]; then

  SEVENZIP_NON_BLOCKING_LOGFILE_SUFFIX=_background_7zipping.log
  echo ""
  echo "7-Zip NON-BLOCKING mode enabled"
  echo "-----------------------"
  echo "Cleaning up any leftover logs..."
  rm -f "${MYSQL_BACKUP_DIR}"*${SEVENZIP_NON_BLOCKING_LOGFILE_SUFFIX}

fi

## Iterate over DBs
for DATABASE in $DATABASES
do
  ## Dump filename
  DUMPFILE_FULLPATH=${MYSQL_BACKUP_DIR}${HOSTNAME}_${DATABASE}_${DOWEEK}.sql
  
  ## mysqldump
  echo ""
  echo "mysqldumping"
  echo "------------"
  echo "$DUMPFILE_FULLPATH"
  mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" $MYSQLDUMP_OPTIONS --databases "$DATABASE" > "$DUMPFILE_FULLPATH"
  ## autocommit optimization - header
  NO_AUTOCOMMIT_TEXT="SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, AUTOCOMMIT=0;"
  sed -i "/Server version/ a ${NO_AUTOCOMMIT_TEXT}" "$DUMPFILE_FULLPATH"

  ## autocommit optimization - footer
  echo "COMMIT;" >> "$DUMPFILE_FULLPATH"
  echo "SET AUTOCOMMIT=@OLD_AUTOCOMMIT" >> "$DUMPFILE_FULLPATH"
  
  ## 7z compression
  echo ""
  echo "7-zipping"
  echo "---------"
  echo ${DUMPFILE_FULLPATH}.7z
  rm -f "${DUMPFILE_FULLPATH}.7z"
  
  if [ ${SEVENZIP_NON_BLOCKING} == 1 ]; then

    bash "${SCRIPT_DIR}7zip-log-to-file.sh" "${SEVENZIP_COMPRESS_OPTIONS}" "${DUMPFILE_FULLPATH}.7z" "${DUMPFILE_FULLPATH}" "${DUMPFILE_FULLPATH}${SEVENZIP_NON_BLOCKING_LOGFILE_SUFFIX}" &

  else
  
    7za a ${SEVENZIP_COMPRESS_OPTIONS} "${DUMPFILE_FULLPATH}.7z" "${DUMPFILE_FULLPATH}"
    
  fi
  
done

## Remove old files
echo ""
echo "Deleting old files"
echo "------------------"

if [ -z "$1" ]; then

  echo "Current retention: ##${RETENTION_DAYS}## day(s)"
  find "${MYSQL_BACKUP_DIR}" -type f -mtime +${RETENTION_DAYS} \( -name "*.sql.7z" -o -name "*.sql" -o -name "*.log" \)
  find "${MYSQL_BACKUP_DIR}" -type f -mtime +${RETENTION_DAYS} \( -name "*.sql.7z" -o -name "*.sql" -o -name "*.log" \) -delete
  
else

  echo "Skipping when running with a profile"
fi


## Display files
echo ""
echo "Backup file list"
echo "-----------------"
ls -latrh "${MYSQL_BACKUP_DIR}"

zzmysqldumpPrintEndFooter

