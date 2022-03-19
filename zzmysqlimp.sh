#!/usr/bin/env bash
echo ""

## Script name
SCRIPT_NAME=zzmysqlimp

source "/usr/local/turbolab.it/zzmysqldump/base.sh"

## Checking input file
DUMP_FULLPATH=$(readlink -f "$1")

if [ -z "$DUMP_FULLPATH" ] || [ ! -f "$DUMP_FULLPATH" ]; then

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
DUMPFILE_FULLPATH=${DUMP_FULLPATH%.7z}

echo ""
echo "Un-7zipping the file"
echo "--------------------"
echo ${1}
echo ""

if [ ! -f "$DUMPFILE_FULLPATH" ] || [ "$(find "$DUMPFILE_FULLPATH" -mmin +3600)" ]; then

  7za e "${1}" -o"${DUMP_DIR}" -y
  
else

  echo "The extracted file exists and was created today. Skipping the un-7zipping!"
  
fi

echo ""
echo "Importing the extracted dump"
echo "----------------------------"

echo ${DUMPFILE_FULLPATH}
echo ""
mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" < "$DUMPFILE_FULLPATH"


zzmysqldumpPrintEndFooter

