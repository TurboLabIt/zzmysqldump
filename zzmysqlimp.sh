#!/bin/bash
clear

## Script name
SCRIPT_NAME=zzmysqli

## Title and graphics
FRAME="O===========================================================O"
echo "$FRAME"
echo "      $SCRIPT_NAME - $(date)"
echo "$FRAME"


## Enviroment variables
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
HOSTNAME="$(hostname)"

## Checking input file
DUMP_FULLPATH=$(readlink -f "$1")

if [[ (-z "$DUMP_FULLPATH") || ( ! -f "$DUMP_FULLPATH" ) ]]; then

		echo ""
		echo "vvvvvvvvvvvvvvvvvvvv"
		echo "Catastrophic error!!"
		echo "^^^^^^^^^^^^^^^^^^^^"
		echo "Dump to import not found"
		echo "[X] $DUMP_FULLPATH"

		echo ""
		echo "The End"
		echo "-------"
		echo $(date)
		echo "$FRAME"
		exit
	
fi

DUMP_DIR=$(dirname "$DUMP_FULLPATH")/


## Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT_FULLPATH=$(readlink -f "$0")

## Absolute path this script is in, thus /home/user/bin
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/

## Config files
CONFIGFILE_NAME=zzmysqldump.conf
CONFIGFILE_FULLPATH_DEFAULT=${SCRIPT_DIR}zzmysqldump.default.conf
CONFIGFILE_MYSQL_FULLPATH_ETC=/etc/turbolab.it/mysql.conf
CONFIGFILE_FULLPATH_ETC=/etc/turbolab.it/$CONFIGFILE_NAME
CONFIGFILE_FULLPATH_DIR=${SCRIPT_DIR}$CONFIGFILE_NAME


for CONFIGFILE_FULLPATH in "$CONFIGFILE_FULLPATH_DEFAULT" "$CONFIGFILE_MYSQL_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_DIR" "$CONFIGFILE_PROFILE_FULLPATH_ETC" "$CONFIGFILE_PROFILE_FULLPATH_DIR" "$CONFIGFILE_EXPLICIT"
do
	if [ -f "$CONFIGFILE_FULLPATH" ]; then
		source "$CONFIGFILE_FULLPATH"
	fi
done


echo ""
echo "Un-7zipping the file"
echo "--------------------"
echo ${1}
echo ""
7za e "${1}" -o"${DUMP_DIR}" -y


echo ""
echo "Importing the extracted dump"
echo "----------------------------"
DUMPFILE_FULLPATH=${DUMP_FULLPATH%.7z}
echo ${DUMPFILE_FULLPATH}
echo ""

mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" < "$DUMPFILE_FULLPATH"

echo ""
echo "Time took"
echo "---------"
echo "$((($(date +%s)-$TIME_START)/60)) min."

echo ""
echo "The End"
echo "-------"
echo $(date)
echo "$FRAME"
