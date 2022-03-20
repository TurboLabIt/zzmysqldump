#!/usr/bin/env bash
echo ""

## Script name
SCRIPT_NAME="zzmysqldump"

source "/usr/local/turbolab.it/zzmysqldump/base.sh"
bash "/usr/local/turbolab.it/zzmysqldump/zzmysqldump.sh" > "${MYSQL_BACKUP_DIR}automatic-backup.log" 2>&1

