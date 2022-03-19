## Title and graphics
FRAME="O===========================================================O"
echo "$FRAME"
echo -e "\t $SCRIPT_NAME - $(date)"
echo "$FRAME"

## Enviroment variables
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
HOSTNAME="$(hostname)"

## Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT_FULLPATH=$(readlink -f "$0")

## Absolute path this script is in, thus /home/user/bin
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/

## Default config files
CONFIGFILE_FULLPATH_DEFAULT=${SCRIPT_DIR}${SCRIPT_NAME}.default.conf
CONFIGFILE_MYSQL_FULLPATH_ETC=/etc/turbolab.it/mysql.conf
CONFIGFILE_NAME=$SCRIPT_NAME.conf
CONFIGFILE_FULLPATH_ETC=/etc/turbolab.it/$CONFIGFILE_NAME
CONFIGFILE_FULLPATH_DIR=${SCRIPT_DIR}${CONFIGFILE_NAME}

## Config reading function
function zzmysqldumpConfigSet()
{
  for CONFIGFILE_FULLPATH in "$@"
  do
    if [ -f "$CONFIGFILE_FULLPATH" ]; then
      source "$CONFIGFILE_FULLPATH"
    fi
  done
  
  ## Add a slash to the output directory if missing
  MYSQL_BACKUP_DIR="${MYSQL_BACKUP_DIR%/}/"
}

zzmysqldumpConfigSet "$CONFIGFILE_FULLPATH_DEFAULT" "$CONFIGFILE_MYSQL_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_DIR"


## Retrive databases list and test connection
function listDatabases()
{
  echo ""
  echo "Retrieving DBs list"
  echo "-------------------"
  DATABASES=$(mysql -N -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -e 'show databases')

  if [ $? -eq 0 ]; then

    echo $DATABASES
    
  else
  
    zzmysqldumpPrintEndFooter
    exit

  fi
}

## Footer function
function zzmysqldumpPrintEndFooter()
{
  echo ""
  echo "Time took"
  echo "---------"
  echo "$((($(date +%s)-$TIME_START)/60)) min."

  echo ""
  echo "The End"
  echo "-------"
  echo $(date)
  echo "$FRAME"
}

