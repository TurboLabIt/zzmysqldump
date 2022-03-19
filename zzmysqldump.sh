#!/usr/bin/env bash
echo ""

## Script name
SCRIPT_NAME=zzmysqldump

source "/usr/local/turbolab.it/zzmysqldump/base.sh"

## Dump profile requested
if [ ! -z "$1" ]; then

  CONFIGFILE_PROFILE_NAME=${SCRIPT_NAME}.profile.${1}.conf
  CONFIGFILE_PROFILE_FULLPATH_ETC=/etc/turbolab.it/$CONFIGFILE_PROFILE_NAME
  CONFIGFILE_PROFILE_FULLPATH_DIR=${SCRIPT_DIR}$CONFIGFILE_PROFILE_NAME
  
  if [[ "$1" == /* ]]; then
  
    CONFIGFILE_EXPLICIT=$1
    
  fi
  
  if [ ! -f "$CONFIGFILE_PROFILE_FULLPATH_ETC" ] && [ ! -f "$CONFIGFILE_PROFILE_FULLPATH_DIR" ] && [ ! -f "$CONFIGFILE_EXPLICIT" ]; then

    echo ""
    echo "vvvvvvvvvvvvvvvvvvvv"
    echo "Catastrophic error!!"
    echo "^^^^^^^^^^^^^^^^^^^^"
    echo "Profile config file(s) not found:"
    echo "[X] $CONFIGFILE_PROFILE_FULLPATH_ETC"
    echo "[X] $CONFIGFILE_PROFILE_FULLPATH_DIR"
    
    if [ -z "$CONFIGFILE_EXPLICIT" ]; then
    
      echo "[X] no explicit file provided via CLI"
    
    else
    
      echo "[X] $CONFIGFILE_EXPLICIT "
    
    fi


    echo ""
    echo "How to fix it?"
    echo "--------------"
    echo "Create a config file for this profile:"
    echo "sudo cp $CONFIGFILE_FULLPATH_DEFAULT $CONFIGFILE_PROFILE_FULLPATH_ETC && sudo nano $CONFIGFILE_PROFILE_FULLPATH_ETC && sudo chmod u=rw,go=r $CONFIGFILE_PROFILE_FULLPATH_ETC && ${SCRIPT_NAME} $1"

    zzmysqldumpPrintEndFooter
    exit
    
  fi
  
  zzmysqldumpConfigSet "$CONFIGFILE_PROFILE_FULLPATH_ETC" "$CONFIGFILE_PROFILE_FULLPATH_DIR" "$CONFIGFILE_EXPLICIT"
  
fi

## Retrive databases list and test connection
listDatabases

## Create backup directory
echo ""
echo "Creating backup directory"
echo "-------------------------"
echo "${MYSQL_BACKUP_DIR}"
mkdir -p "${MYSQL_BACKUP_DIR}"

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

## Display files
echo ""
echo "Backup file list"
echo "-----------------"
ls -latrh "${MYSQL_BACKUP_DIR}"

zzmysqldumpPrintEndFooter

