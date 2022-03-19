#!/bin/bash
clear

## Script name
SCRIPT_NAME=zzmysqlimp

source "/usr/local/turbolab.it/zzmysqldump/base.sh"

## Checking input file
DUMP_FULLPATH=$(readlink -f "$1")

if [[ (-z "$DUMP_FULLPATH") || ( ! -f "$DUMP_FULLPATH" ) ]]; then

  echo ""
  echo "vvvvvvvvvvvvvvvvvvvv"
  echo "Catastrophic error!!"
  echo "^^^^^^^^^^^^^^^^^^^^"
  echo "Dump to import not found"
  echo "[X] $DUMP_FULLPATH"

  zzmysqldumpPrintEndFooter
  exit
	
fi

DUMP_DIR=$(dirname "$DUMP_FULLPATH")/

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

zzmysqldumpPrintEndFooter

