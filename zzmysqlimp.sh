#!/usr/bin/env bash

SCRIPT_NAME=zzmysqlimp
source "/usr/local/turbolab.it/zzmysqldump/base.sh"

## Checking input file
DUMP_FULLPATH=$(readlink -f "$1")
if [ -z "$DUMP_FULLPATH" ] || [ ! -f "$DUMP_FULLPATH" ]; then

  fxCatastrophicError "Dump to import not found!
  🕳 $DUMP_FULLPATH
  "
fi


fxTitle "Extracting..."
DUMP_DIR=$(dirname "$DUMP_FULLPATH")/
DUMPFILE_FULLPATH=${DUMP_FULLPATH%.7z}

echo "Directory:    ##${DUMP_DIR}##"
echo "Filename:     ##${DUMPFILE_FULLPATH}##"

if [ ! -f "$DUMPFILE_FULLPATH" ] || [ "$(find "$DUMPFILE_FULLPATH" -mmin +3600)" ]; then
  7za e "${1}" -o"${DUMP_DIR}" -y
else
  fxInfo "The extracted file exists and was created today. Skipping the un-7zipping!"
fi

fxTitle "Listing..."
ls -lh "${DUMP_DIR}" | grep $(basename ${DUMPFILE_FULLPATH})


fxTitle "Changing database name..."

function sedReplace()
{
  sed -i "s|${REPLACE_REGEX}|${REPLACE_WITH_TEXT}|g" "${DUMPFILE_FULLPATH}" --regexp-extended
  fxOK "Done"
}

if [ ! -z "$2" ]; then

  fxInfo "OK, the new database name is going to be named #$2#"
  echo ""
  
  REPLACE_REGEX='^-- Current Database: `.+`'
  REPLACE_WITH_TEXT="-- Database name replaced to ##$2## with https://github.com/TurboLabIt/zzmysqldump"
  sed -i "s|${REPLACE_REGEX}|&\n${REPLACE_WITH_TEXT}|g" "${DUMPFILE_FULLPATH}" --regexp-extended
  fxOK "Note added"
  
  REPLACE_REGEX='^/\*!40000 DROP DATABASE IF EXISTS `.+`\*/;'
  REPLACE_WITH_TEXT="/\\*!40000 DROP DATABASE IF EXISTS \`$2\`\\*/;"  
  sedReplace "$REPLACE_REGEX" "$REPLACE_WITH_TEXT"
  
  REPLACE_REGEX='^CREATE DATABASE /\*!32312 IF NOT EXISTS\*/ `.+`'
  REPLACE_WITH_TEXT="CREATE DATABASE /\\*!32312 IF NOT EXISTS\\*/ \`$2\`"  
  sedReplace "$REPLACE_REGEX" "$REPLACE_WITH_TEXT"
  
  REPLACE_REGEX='^USE `.+`;'
  REPLACE_WITH_TEXT="USE \`$2\`;"  
  sedReplace "$REPLACE_REGEX" "$REPLACE_WITH_TEXT"

else

  fxInfo "New database name not provided. Using the same name provided by the dump"
fi


fxTitle "Importing the extracted dump..."
mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" < "$DUMPFILE_FULLPATH"


fxEndFooter
