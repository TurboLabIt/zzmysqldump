#!/usr/bin/env bash
echo ""

## Script name
SCRIPT_NAME=zzmysqlclean

source "/usr/local/turbolab.it/zzmysqldump/base.sh"

## Parameter validation
if [ -z "$1" ]; then

  echo ""
  echo "vvvvvvvvvvvvvvvvvvvv"
  echo "Catastrophic error!!"
  echo "^^^^^^^^^^^^^^^^^^^^"
  echo "You MUST provide the name of the database to clean as the first argument"
  echo ""
  exit
  
fi

DATABASE_NAME="$1"

## Retrive databases list and test connection
listDatabases


TABLES=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" --skip-column-names --silent -e 'show tables' "$DATABASE_NAME" | tail -n +1)

echo ""
echo "Cleaning"
echo "---------"
while IFS= read -r line; do

  if [ "$line" != "migration_versions" ]; then

    echo "->Table: $line"
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -e "SET FOREIGN_KEY_CHECKS = 0; TRUNCATE TABLE $line" "$DATABASE_NAME"
    echo ""

  fi

done <<< "$TABLES"

zzmysqldumpPrintEndFooter

