#!/bin/bash
clear

## Script name
SCRIPT_NAME=zzmysqldump

## Title and graphics
FRAME="O===========================================================O"
echo "$FRAME"
echo "      $SCRIPT_NAME - $(date)"
echo "$FRAME"

## Enviroment variables
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
HOSTNAME="$(hostname)"

## Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT_FULLPATH=$(readlink -f "$0")

## Absolute path this script is in, thus /home/user/bin
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/

## Config files
CONFIGFILE_NAME=$SCRIPT_NAME.conf
CONFIGFILE_FULLPATH_DEFAULT=${SCRIPT_DIR}$SCRIPT_NAME.default.conf
CONFIGFILE_MYSQL_FULLPATH_ETC=/etc/zzturboscript/mysql.conf
CONFIGFILE_FULLPATH_ETC=/etc/zzturboscript/$CONFIGFILE_NAME
CONFIGFILE_FULLPATH_DIR=${SCRIPT_DIR}$CONFIGFILE_NAME

for CONFIGFILE_FULLPATH in "$CONFIGFILE_FULLPATH_DEFAULT" "$CONFIGFILE_MYSQL_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_DIR"
do
	if [ -f "$CONFIGFILE_FULLPATH" ]; then
		source "$CONFIGFILE_FULLPATH"
	fi
done

## Create backup directory
mkdir -p "${MYSQL_BACKUP_DIR}"

## Retrive databases list and test connection
DATABASES=$(mysql -N -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -e 'show databases' | egrep -vi "$MYSQL_DB_EXCLUDE")

## Iterate over DBs
for DATABASE in $DATABASES
do
	## Dump filename
	DUMPFILE_FULLPATH=${MYSQL_BACKUP_DIR}${HOSTNAME}_${DATABASE}_${DOWEEK}.sql
	
	## mysqldump
	mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" $MYSQLDUMP_OPTIONS --databases "$DATABASE" > "$DUMPFILE_FULLPATH"
	
	## 7z compression
	7z a ${SEVENZIP_COMPRESS_OPTIONS} "${DUMPFILE_FULLPATH}.7z" "${DUMPFILE_FULLPATH}"
	
	## remove uncompressed dump
	rm -f "${DUMPFILE_FULLPATH}"
done

## Display files
echo ""
echo "Backup file list"
echo "-----------------"
ls -trlh /home/zane/backup/mysql

echo ""
echo "Time took"
echo "---------"
echo "$((($(date +%s)-$TIME_START)/60)) min."

echo ""
echo "Script end"
echo "----------"
echo $(date)

echo ""
echo "$FRAME"
