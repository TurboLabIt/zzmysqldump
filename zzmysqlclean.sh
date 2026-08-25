#!/usr/bin/env bash

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi
## zzmysqlclean is part of the zzmysqldump app: load zzmysqldump's config
SCRIPT_NAME=zzmysqldump
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "🧹 zzmysqlclean"

fxConfigLoader


if [ -z "$1" ]; then
  fxCatastrophicError "You MUST provide the name of the database to clean as the first argument"
fi

DATABASE_NAME="$1"


fxTitle "🔌 Connecting..."
DATABASES=$(mysql -N -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -e 'show databases')
if [ $? -ne 0 ]; then
  fxCatastrophicError "Database connection failed"
fi

if ! echo "$DATABASES" | grep -qx "$DATABASE_NAME"; then
  fxCatastrophicError "Database ##${DATABASE_NAME}## not found on ##${MYSQL_HOST}##"
fi


fxTitle "🧹 Truncating every table of ##${DATABASE_NAME}##..."
TABLES=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" --skip-column-names --silent -e 'show tables' "$DATABASE_NAME")

while IFS= read -r TABLE_NAME; do

  if [ -z "$TABLE_NAME" ] || [ "$TABLE_NAME" = "migration_versions" ]; then
    continue
  fi

  echo "-> Table: ${TABLE_NAME}"
  mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -e "SET FOREIGN_KEY_CHECKS = 0; TRUNCATE TABLE ${TABLE_NAME}" "$DATABASE_NAME"

done <<< "$TABLES"


fxEndFooter
