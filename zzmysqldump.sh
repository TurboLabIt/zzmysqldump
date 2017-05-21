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
CONFIGFILE_MYSQL_FULLPATH_ETC=/etc/turbolab.it/mysql.conf
CONFIGFILE_FULLPATH_ETC=/etc/turbolab.it/$CONFIGFILE_NAME
CONFIGFILE_FULLPATH_DIR=${SCRIPT_DIR}$CONFIGFILE_NAME

## Dump profile requested
if [ ! -z "$1" ]; then

	CONFIGFILE_PROFILE_NAME=${SCRIPT_NAME}.profile.${1}.conf
	CONFIGFILE_PROFILE_FULLPATH_ETC=/etc/turbolab.it/$CONFIGFILE_PROFILE_NAME
	CONFIGFILE_PROFILE_FULLPATH_DIR=${SCRIPT_DIR}$CONFIGFILE_PROFILE_NAME

	if [ ! -f "$CONFIGFILE_PROFILE_FULLPATH_ETC" ] && [ ! -f "$CONFIGFILE_PROFILE_FULLPATH_DIR" ]; then

		echo ""
		echo "vvvvvvvvvvvvvvvvvvvv"
		echo "Catastrophic error!!"
		echo "^^^^^^^^^^^^^^^^^^^^"
		echo "Profile config file(s) not found:"
		echo "[X] $CONFIGFILE_PROFILE_FULLPATH_ETC"
		echo "[X] $CONFIGFILE_PROFILE_FULLPATH_DIR"

		echo ""
		echo "How to fix it?"
		echo "--------------"
		echo "Create a config file for this profile:"
		echo "sudo cp $CONFIGFILE_FULLPATH_DEFAULT $CONFIGFILE_PROFILE_FULLPATH_ETC && sudo nano $CONFIGFILE_PROFILE_FULLPATH_ETC && sudo chmod ugo=rw /etc/turbolab.it/*.conf"

		echo ""
		echo "The End"
		echo "-------"
		echo $(date)
		echo "$FRAME"
		exit
	fi
fi


for CONFIGFILE_FULLPATH in "$CONFIGFILE_FULLPATH_DEFAULT" "$CONFIGFILE_MYSQL_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_DIR" "$CONFIGFILE_PROFILE_FULLPATH_ETC" "$CONFIGFILE_PROFILE_FULLPATH_DIR"
do
	if [ -f "$CONFIGFILE_FULLPATH" ]; then
		source "$CONFIGFILE_FULLPATH"
	fi
done

## Create backup directory
echo ""
echo "Creating backup directory"
echo "-------------------------"
echo "${MYSQL_BACKUP_DIR}"
mkdir -p "${MYSQL_BACKUP_DIR}"

## Retrive databases list and test connection
echo ""
echo "Retrieving DBs list"
echo "-------------------"
DATABASES=$(mysql -N -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -e 'show databases')
echo $DATABASES

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
	mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" $MYSQLDUMP_OPTIONS --databases "$DATABASE" > "$DUMPFILE_FULLPATH"
	
	## 7z compression
	echo ""
	echo "7-zipping"
	echo "---------"
	echo ${DUMPFILE_FULLPATH}.7z
	7z a ${SEVENZIP_COMPRESS_OPTIONS} "${DUMPFILE_FULLPATH}.7z" "${DUMPFILE_FULLPATH}"
	
	## remove uncompressed dump
	echo ""
	echo "Removing uncompressed dump"
	echo "--------------------------"
	echo "$DUMPFILE_FULLPATH"
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
echo "The End"
echo "-------"
echo $(date)
echo "$FRAME"
